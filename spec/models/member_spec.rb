require "rails_helper"

RSpec.describe Member, type: :model do
  let(:rank_one)   { build(:member, current_rank: 1) }
  let(:rank_two)   { build(:member, current_rank: 2) }
  let(:rank_three) { build(:member, current_rank: 3) }

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

  describe "#ranked_higher?" do
    it "returns true if the member is ranked higher than the other member" do
      expect(rank_one.ranked_higher?(rank_two)).to be true
    end

    it "returns false if the member is not ranked higher than the other member" do
      expect(rank_two.ranked_higher?(rank_one)).to be false
    end
  end

  describe "#ranked_lower?" do
    it "returns true if the member is ranked lower than the other member" do
      expect(rank_two.ranked_lower?(rank_one)).to be true
    end

    it "returns false if the member is not ranked lower than the other member" do
      expect(rank_one.ranked_lower?(rank_two)).to be false
    end
  end

  describe "#adjacent?" do
    it "identifies adjacent members" do
      expect(rank_one.adjacent?(rank_two)).to   be true
      expect(rank_one.adjacent?(rank_three)).to be false
    end
  end

  describe "#lose_rank!" do
    it "decreases the member's rank by 1" do
      rank_two.save!

      expect { rank_two.lose_rank! }.to change { rank_two.reload.current_rank }.by(1)
    end
  end

  describe "#gain_rank!" do
    it "increases the member's rank by 1" do
      rank_two.save!

      expect { rank_two.gain_rank! }.to change { rank_two.reload.current_rank }.by(-1)
    end
  end
end
