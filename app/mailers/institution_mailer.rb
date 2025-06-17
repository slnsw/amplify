# frozen_string_literal: true

class InstitutionMailer < ApplicationMailer
  def delete_institution(institution_name, user_email)
    @institution_name = institution_name
    subject_line = "Amplify: #{@institution_name} was succesfully deleted."
    mail(to: user_email, subject: subject_line)
  end
end
