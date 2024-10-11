module Twilio
  class SmsSender
    TWILIO_ACCOUNT_SID = 'AC9e365128237c5106c6cae438f375b612'
    TWILIO_AUTH_TOKEN = '688a2b9cf20cbdbabb56c083ccc30f60'
    TWILIO_FROM_PHONE =  "+12062021697"
    TWILIO_TEST_PHONE = "+21650122449"

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