class Api::V1::DocumentsController < ApplicationController


  def create
    document = Document.new(document_params)

    if document.save
      # Use document_data method to include file_type and document_url
      render json: { message: 'Document uploaded successfully', document: document_data(document) }, status: :created, methods: [:document_url]
    else
      render json: { errors: document.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def show
    document = Document.find(params[:id])
    if document.file.attached?
      send_data document.file.download, filename: document.title, type: document.file.content_type, disposition: 'attachment'
    else
      render json: { error: 'File not found' }, status: :not_found
    end
  end
  def destroy
    doctor = Doctor.find(params[:id])

    documents = Document.current.where(doctor_id: doctor.id).all
    # Use document_data method to include file_type and document_url
    render json: documents.map { |doc| document_data(doc) }, status: :ok, methods: [:document_url]
  end

  private

  def document_params
    params.require(:document).permit(:title, :file, :doctor_id)
  end

  # Method to format document data including file_type and document_url
  def document_data(doc)
    {
      id: doc.id,
      title: doc.title,
      file_type: doc.file.attached? ? doc.file.content_type : nil,  # Include file type
      size: doc.file.attached? ? (doc.file.blob.byte_size.to_f / 1_024).round(2) : 0,  # Convert size to KB

      document_url: doc.file.attached? ? url_for(doc.file) : nil    # Include document URL
    }
  end
end
