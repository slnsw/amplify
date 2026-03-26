# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::UserContributions do
  let(:institution) { create(:institution) }
  let(:collection) { create(:collection, institution: institution) }
  let(:user) { create(:user) }
  let(:transcript_line) do
    create(:transcript_line, transcript: create(:transcript, collection: collection))
  end

  # Shared helper to create an edit for the default user on the default transcript line
  def create_edit(user_id: user.id, line: transcript_line, attrs: {})
    create(:transcript_edit,
           user_id: user_id,
           transcript_line: line,
           transcript: line.transcript,
           is_deleted: 0,
           **attrs)
  end

  describe '#results' do
    context 'with no filters' do
      subject(:service) { described_class.new({}) }

      before { create_edit }

      it 'returns a paginated collection' do
        expect(service.results).to be_a(WillPaginate::Collection)
      end

      it 'includes users who have made edits' do
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).to include(user.id)
      end
    end

    context 'with start_date filter' do
      before { create_edit }

      it 'returns a paginated collection regardless of date filters' do
        service = described_class.new(start_date: 7.days.ago.to_s)
        expect(service.results).to be_a(WillPaginate::Collection)
      end
    end

    context 'with collection_id filter' do
      subject(:service) { described_class.new(collection_id: collection.id) }

      before { create_edit }

      it 'filters results to the specified collection' do
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).to include(user.id)
      end

      it 'excludes users from other collections' do
        other_collection = create(:collection, institution: institution)
        role = UserRole.find_by(name: 'user') || create(:user_role)
        other_user = User.create!(name: 'Other User', email: "other_#{SecureRandom.hex(4)}@example.com",
                                  password: 'Password123', user_role: role, confirmed_at: Time.zone.now)
        other_line = create(:transcript_line, transcript: create(:transcript, collection: other_collection))
        create_edit(user_id: other_user.id, line: other_line)
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).not_to include(other_user.id)
      end
    end

    context 'with institution_id filter' do
      subject(:service) { described_class.new(institution_id: institution.id) }

      before { create_edit }

      it 'filters results to the specified institution' do
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).to include(user.id)
      end
    end

    context 'with SQL injection attempt in collection_id' do
      subject(:service) { described_class.new(collection_id: '1; DROP TABLE collections;--') }

      before { create_edit }

      it 'does not raise an error' do
        expect { service.results }.not_to raise_error
      end

      it 'does not delete collections' do
        service.results
        expect(Collection.count).to be >= 1
      end

      it 'skips the filter entirely (non-integer collection_id is ignored)' do
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).to include(user.id)
      end
    end

    context 'with non-integer collection_id (e.g. "abc")' do
      subject(:service) { described_class.new(collection_id: 'abc') }

      before { create_edit }

      it 'skips the filter and returns results unfiltered' do
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).to include(user.id)
      end
    end

    context 'with SQL injection attempt in institution_id' do
      subject(:service) { described_class.new(institution_id: '1 OR 1=1') }

      before { create_edit }

      it 'does not raise an error' do
        expect { service.results }.not_to raise_error
      end

      it 'skips the filter entirely (non-integer institution_id is ignored)' do
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).to include(user.id)
      end
    end

    context 'with non-integer institution_id (e.g. "abc")' do
      subject(:service) { described_class.new(institution_id: 'abc') }

      before { create_edit }

      it 'skips the filter and returns results unfiltered' do
        ids = service.results.map { |r| r['user_id'].to_i }
        expect(ids).to include(user.id)
      end
    end

    context 'with pagination' do
      subject(:service) { described_class.new(per_page: 1, page: 1) }

      before do
        create_edit
        # Create additional users reusing the existing user_role to avoid unique constraint
        role = UserRole.find_by(name: 'user') || create(:user_role)
        3.times do
          u = create(:user, user_role: role)
          create_edit(user_id: u.id)
        end
      end

      it 'respects per_page limit' do
        expect(service.results.length).to eq(1)
      end
    end
  end

  describe '#to_csv' do
    subject(:service) { described_class.new({}) }

    before { create_edit }

    it 'generates a CSV string' do
      csv = service.to_csv
      expect(csv).to be_a(String)
    end

    it 'includes the expected headers' do
      expect(service.to_csv).to include('User ID', 'Name')
    end

    it 'includes data rows' do
      rows = CSV.parse(service.to_csv, headers: true)
      user_ids = rows.map { |r| r['User ID'].to_i }
      expect(user_ids).to include(user.id)
    end

    it 'aligns data values with header labels (Edits before Lines)' do
      rows = CSV.parse(service.to_csv, headers: true)
      row = rows.find { |r| r['User ID'].to_i == user.id }
      # The edit we created counts as 1 edit on 1 distinct line
      expect(row['Edits'].to_i).to eq(1)
    end

    it 'reports correct line count under the Lines header' do
      rows = CSV.parse(service.to_csv, headers: true)
      row = rows.find { |r| r['User ID'].to_i == user.id }
      expect(row['Lines'].to_i).to eq(1)
    end
  end
end
