class VerifyPaymentJob < ApplicationJob
  queue_as :default

  def perform
    # Find all payments that are pending
    pending_payments = Payment.where(status: :pending)

    pending_payments.each do |payment|
      # Perform verification for each payment
      verify_payment(payment)
    end
  end

  private

  def verify_payment(payment)
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
        payment.update(status: :approved)
        payment.consultation.update(is_payed: true)
        ActionCable.server.broadcast "PaymentChannel", {
          message: "Payment for online consultation on ##{payment.consultation.appointment} has been approved.",
          status: "sent",
          subject: "payment success",
          sent_at: Time.current
        }
      end
    else
      payment.update(status: :failed)
    end
  end
end
