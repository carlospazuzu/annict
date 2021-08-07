# frozen_string_literal: true

module Beta
  module Mutations
    class UpdateRecord < Beta::Mutations::Base
      argument :record_id, ID, required: true
      argument :comment, String, required: false
      argument :rating_state, Beta::Types::Enums::RatingState, required: false
      argument :share_twitter, Boolean, required: false
      argument :share_facebook, Boolean, required: false

      field :record, Beta::Types::Objects::RecordType, null: true

      def resolve(record_id:, comment: nil, rating_state: nil, share_twitter: nil, share_facebook: nil)
        raise Annict::Errors::InvalidAPITokenScopeError unless context[:doorkeeper_token].writable?

        viewer = context[:viewer]
        episode_record = viewer.episode_records.only_kept.find_by_graphql_id(record_id)

        form = Forms::EpisodeRecordForm.new(
          comment: comment,
          episode: episode_record.episode,
          oauth_application: context[:doorkeeper_token].application,
          rating: rating_state&.downcase,
          record: episode_record.record,
          share_to_twitter: share_twitter
        )

        if form.invalid?
          raise GraphQL::ExecutionError, form.errors.full_messages.first
        end

        result = Updaters::EpisodeRecordUpdater.new(
          user: viewer,
          form: form
        ).call

        {
          record: result.record.episode_record
        }
      end
    end
  end
end
