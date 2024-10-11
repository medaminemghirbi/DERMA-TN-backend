module Twilio
  class SmsSender
    TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID']
    TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
    TWILIO_FROM_PHONE = ENV['TWILIO_FROM_PHONE']
    TWILIO_TEST_PHONE = ENV['TWILIO_TEST_PHONE']

    def initialize(body:, to_phone_number:)
      @body = body
      @to_phone_number = to_phone_number
    end

    def send_sms
      @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
      message = @client.messages
        .create(
          body: @body,
          from: ENV['TWILIO_FROM_PHONE'],
          to: to(@to_phone_number)
        )
      puts message.sid
    end

    private

    def to(to_phone_number)
      return ENV['TWILIO_TEST_PHONE'] if Rails.env.development?

      to_phone_number
    end
  end
end