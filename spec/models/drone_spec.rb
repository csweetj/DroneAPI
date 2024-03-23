require 'rails_helper'

RSpec.describe Drone, type: :model do

  # 正しく登録できる場合_1：
  # drone_registration_idが正しいフォーマット（JUから始まる13桁の英数字）であれば登録可能
  it "is valid with valid attributes" do
    drone = build(:drone)
    expect(drone).to be_valid
  end

  #===================================================

  # 正しく登録できない場合_1：
  # drone_registration_idが正しくないフォーマット（JUから始まる13桁の英数字）であれば登録不可
  it "is not valid with a drone_registration_id that does not start with 'JU' followed by 11 digits" do
    # 頭文字がJUではない、13桁未満、13桁超え、空文字
    invalid_ids = ["XX12345678901", "JU123456789", "JUABCDEFGHIJKL", ""]
    invalid_ids.each do |id|
      drone = build(:drone, drone_registration_id: id)
      expect(drone).not_to be_valid, "drone_registration_id was #{id}"
    end
  end
end
