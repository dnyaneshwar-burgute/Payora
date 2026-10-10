module Admin
  class OrganizationsController < BaseController
    EVENTS = %w[ approve reject ].freeze

    before_action :set_organization, only: %i[ show change_state ]

    def index
      @status = params[:status].presence_in(Organization.aasm.states.map(&:name).map(&:to_s))
      @organizations = Organization.order(created_at: :desc)
      @organizations = @organizations.where(status: @status) if @status
    end

    def show
    end

    def change_state
      if fire_event
        redirect_to admin_organization_path(@organization), notice: state_changed_notice
      else
        flash.now[:alert] = @organization.errors.full_messages_for(:base).to_sentence.presence
        render :show, status: :unprocessable_entity
      end
    end

    private
      def set_organization
        @organization = Organization.find(params[:id])
      end

      def fire_event
        event = params[:event].to_s
        unless event.in?(EVENTS)
          @organization.errors.add(:base, "Unknown review action.")
          return false
        end

        # Lock before assigning attributes: lock! reloads and refuses dirty records.
        @organization.with_lock do
          if !@organization.aasm.may_fire_event?(event.to_sym)
            @organization.errors.add(:base, "This organization has already been reviewed.")
            false
          elsif event == "approve"
            @organization.approve!(Current.user)
          else
            @organization.rejection_reason = params[:rejection_reason]
            @organization.reject!
          end
        end
      end

      def state_changed_notice
        if @organization.approved?
          "#{@organization.name} approved. The owner has been sent an invitation."
        else
          "#{@organization.name} rejected."
        end
      end
  end
end
