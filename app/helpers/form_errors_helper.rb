module FormErrorsHelper
  def field_class(record, attribute)
    record.errors[attribute].any? ? "form-control is-invalid" : "form-control"
  end

  def field_errors(record, attribute)
    return if record.errors[attribute].none?

    tag.div(record.errors.full_messages_for(attribute).to_sentence, class: "invalid-feedback")
  end
end
