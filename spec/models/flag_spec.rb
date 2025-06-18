RSpec.describe Flag, type: :model do
  describe "saving flag" do
    let(:flag) { create(:flag) }

    context "without a flag type" do
      # custom text
      it "saves flag type" do
        expect(flag.flag_type).not_to be(nil)
      end
    end
  end
end
