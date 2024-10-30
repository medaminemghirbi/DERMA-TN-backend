# app/controllers/predictions_controller.rb
class PredictionsController < ApplicationController
  def predict
    # Assuming the image is uploaded as part of the request
    image = params[:file]
    doctor = Doctor.find(params[:doctor_id])

    if DoctorUsage.usage_limit_reached?(doctor, doctor.daily_limit)
      render json: { error: 'limit reached Of Using IA. Please upgrade your plan.' }, status: 403
      return
    end

    # Save the uploaded file to a temporary location
    image_path = Rails.root.join('tmp', image.original_filename)
    File.open(image_path, 'wb') do |file|
      file.write(image.read)
    end

    # Call the Machine Learning service with the image path
    prediction_output = RunMachineLearning.call(image_path)

    # Ensure the output is not nil or empty
    if prediction_output.nil? || prediction_output.empty?
      render json: { error: 'Failed to get a valid prediction from the model' }, status: 500
      return
    end

    # Track doctor's usage
    DoctorUsage.track_usage(doctor)


    # Parse the output from the Python script
    lines = prediction_output.split("\n")

    if lines.size < 2
      render json: { error: 'Prediction format is incorrect' }, status: 500
      return
    end

    # Parse predicted class and probability
    predicted_class = lines[0]&.gsub("Predicted class: ", "") || "Unknown"
    probability = lines[1]&.gsub("Probability: ", "") || "0"

    # Clean up the temporary file
    File.delete(image_path)
    maladie = Maladie.find_by(maladie_name: predicted_class)
    # Return the result as JSON
    render json: { predicted_class: predicted_class, maladie: maladie, probability: probability.strip }
  end
end
