class InvoicesMailbox < ApplicationMailbox

  def process
    pp "🔥🎉😘"
    pp mail.subject
  end

  private 

  # # Callbacks specify prerequisites to processing
  # before_processing :require_projects

  # def process
  #   # Record the forward on the one project, or…
  #   if forwarder.projects.one?
  #     record_forward
  #   else
  #     # …involve a second Action Mailer to ask which project to forward into.
  #     request_forwarding_project
  #   end
  # end

  # private

  # def require_projects
  #   if forwarder.projects.none?
  #     # Use Action Mailers to bounce incoming emails back to sender – this halts processing
  #     bounce_with Forwards::BounceMailer.no_projects(inbound_email, forwarder: forwarder)
  #   end
  # end

  # def record_forward
  #   forwarder.forwards.create subject: mail.subject, content: mail.content
  # end

  # def request_forwarding_project
  #   Forwards::RoutingMailer.choose_project(inbound_email, forwarder: forwarder).deliver_now
  # end

  # def forwarder
  #   @forwarder ||= User.find_by(email_address: mail.from)
  # end
end
