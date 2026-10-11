module Admin
  class OrganizationsController < BaseController
    EVENTS = %w[ approve reject ].freeze

    before_action :set_organization, only: %i[ show change_state ]

    def index
      respond_to do |format|
        format.html { render template: "spa/index" }
        format.json { render json: index_json }
      end
    end

    def show
      respond_to do |format|
        format.html { render template: "spa/index" }
        format.json { render json: { organization: organization_detail(@organization) } }
      end
    end

    def change_state
      if fire_event
        render json: { organization: organization_detail(@organization), notice: state_changed_notice }
      else
        render json: review_error_json, status: :unprocessable_entity
      end
    end

    private
      def set_organization
        @organization = Organization.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise unless request.format.json?

        render json: { error: "Organization not found." }, status: :not_found
      end

      def index_json
        status = params[:status].presence_in(organization_statuses)
        organizations = Organization.order(created_at: :desc)
        organizations = organizations.where(status: status) if status

        {
          status: status,
          statuses: organization_statuses,
          organizations: organizations.map { |organization| organization_summary(organization) }
        }
      end

      def organization_statuses
        Organization.aasm.states.map { |state| state.name.to_s }
      end

      def organization_summary(organization)
        {
          id: organization.id,
          name: organization.name,
          host: organization.host,
          status: organization.status,
          created_at: organization.created_at
        }
      end

      def organization_detail(organization)
        organization_summary(organization).merge(
          rejection_reason: organization.rejection_reason,
          owners: organization.owners.map { |owner|
            { full_name: owner.full_name, email_address: owner.email_address }
          }
        )
      end

      def review_error_json
        field_errors = @organization.errors.group_by_attribute.except(:base).to_h do |attribute, attribute_errors|
          [ attribute.to_s, attribute_errors.map(&:full_message) ]
        end

        {
          error: @organization.errors.full_messages_for(:base).to_sentence.presence,
          field_errors: field_errors
        }
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
