# frozen_string_literal: true

module UidValidation
  extend ActiveSupport::Concern

  included do
    # validation: no spaces
    #             no spacial chars
    #             only a-z, A-Z, 0-9, _ and - allowed
    #
    validates :uid, format: { with: /\A^[a-zA-Z0-9_-]*$\z/ }, length: { in: 1..50 }
  end
end
