require "rails_helper"

RSpec.describe Member, type: :model do
  describe "#set_current_rank" do
    it "starts at rank 1 when no members exist" do
      member = create(:member)

      expect(member.current_rank).to eq(1)
    end

    it "assigns the next rank after the current maximum" do
      existing_member = create(:member)
      existing_member.update_column(:current_rank, 7)

      member = create(:member)

      expect(member.current_rank).to eq(8)
    end
  end
end