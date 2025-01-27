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

      # Render the URL as response
      render json: {url: payment_url}
    else
      render json: {error: "Failed to generate payment URL"}, status: :unprocessable_entity
    end
  end


    
  def generate_facture
    consultation = Consultation.find(params[:id])

    # Call the FactureService to generate the PDF
    pdf_path = FactureService.generate(consultation)

    # Send the PDF as a response
    send_file pdf_path, type: "application/pdf", disposition: "inline", filename: "facture_#{consultation.id}.pdf"
  end

end
