require "net/http"
require "uri"

class Api::V1::PaymentsController < ApplicationController
  def create_payment
    consultation = Consultation.find(params[:consultation_id])

    payload = {
      app_token: ENV["FLOUCI_APP_TOKEN"],
      app_secret: ENV["FLOUCI_APP_SECRET"],
      accept_card: "true",
      amount: consultation.doctor.amount || 1000,
      session_timeout_secs: 1800,
      success_link: "http://localhost:4200/patient/appointment-request/?payment_id=#{consultation.id}",
      fail_link: "http://localhost:4200/patient/appointment-request/fail",
      developer_tracking_id: consultation.id.to_s
    }

    uri = URI.parse("https://developers.flouci.com/api/generate_payment")
    response = Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")
    payment_data = JSON.parse(response.body)

    if payment_data.dig("result", "success")
      payment_url = payment_data["result"]["link"]
      payment_id = payment_data["result"]["payment_id"]

      # Create the Payment record
      Payment.create!(
        consultation: consultation,
        payment_id: payment_id,
        amount: payload[:amount],
        status: 0 # Initial status (e.g., pending)
      )

      # Render the URL as response and start async verification
      render json: {url: payment_url}

      # Trigger asynchronous verification
      verify_payment_async(payment_id)
    else
      render json: {error: "Failed to generate payment URL"}, status: :unprocessable_entity
    end
  end

  private

  # Define a method to asynchronously verify payment after creating it
  def verify_payment_async(payment_id)
    # Call `verify_payment` asynchronously
    Thread.new do
      sleep 20 # Optional delay to allow payment processing
      verify_payment(payment_id)
    end
  end

  def verify_payment(payment_id)
    payment = Payment.find_by(payment_id: payment_id)

    return if payment.nil?

    # Verify payment URL
    uri = URI.parse("https://developers.flouci.com/api/verify_payment/#{payment.payment_id}")

    request = Net::HTTP::Get.new(uri)
    request["apppublic"] = ENV["FLOUCI_APP_TOKEN"]
    request["appsecret"] = ENV["FLOUCI_APP_SECRET"]

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == "200"
      data = JSON.parse(response.body)

      if data["success"] && data.dig("result", "status") == "SUCCESS"
        if data.dig("result", "success_link").present?
          payment.update(status: 0)
        else
          payment.update(status: 1)
          payment.consultation.update(is_payed: true)
        end
      else
        payment.update(status: 2)
      end
    else
      Rails.logger.error "Failed to verify payment with ID: #{payment_id}"
    end
  end
end
