require 'rails_helper'

RSpec.describe FlightsController, type: :request do
  describe 'POST #create' do
    before do
      # Basic認証の設定
      user = ENV["BASIC_AUTH_USERNAME"]
      password = ENV["BASIC_AUTH_PASSWORD"]
      @auth_headers = { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user,password) }
    end

    # 正しく登録できる場合_1：
    context 'with valid flight data' do

      let(:flight_data) do
        [
          {
            droneRegistrationId: FactoryBot.create(:drone).drone_registration_id,
            pilotId: "PL#{Faker::Number.number(digits: 11)}",
            takeOffLatitude: "35.787671",
            takeOffLongitude: "137.797908",
            landingLatitude: "35.787671",
            landingLongitude: "137.797908",
            takeOffTime: "2023-01-02T00:00:00Z",
            landingTime: "2023-01-02T01:00:00Z"
          },
          {
            droneRegistrationId: FactoryBot.create(:drone).drone_registration_id,
            pilotId: "PL#{Faker::Number.number(digits: 11)}",
            takeOffLatitude: "35.787671",
            takeOffLongitude: "137.797908",
            landingLatitude: "35.787671",
            landingLongitude: "137.797908",
            takeOffTime: "2023-01-02T00:00:00Z",
            landingTime: "2023-01-02T01:00:00Z"
          }
        ]
      end

      it 'creates new flights and returns status :created' do
        post '/flights', params: flight_data.to_json, headers: @auth_headers.merge({'CONTENT_TYPE' => 'application/json'})

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["message"]).to eq("飛行記録が正しく保存されました")
      end
    end

    #===================================================

    # 正しく登録できない場合_1：
    #同じドローンに対し、重複した飛行期間があったら登録できない
    context 'with overlapping flight times for the same drone' do
      before do
        # Basic認証の設定
        user = ENV["BASIC_AUTH_USERNAME"]
        password = ENV["BASIC_AUTH_PASSWORD"]
        @auth_headers = { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user,password) }
      end

      let(:drone_registration_id) { FactoryBot.create(:drone).drone_registration_id }
      let(:overlapping_flight_data) do
        [
          {
            droneRegistrationId: drone_registration_id,
            pilotId: "PL#{Faker::Number.number(digits: 11)}",
            takeOffLatitude: Faker::Number.between(from: -90.0, to: 90.0),
            takeOffLongitude: Faker::Number.between(from: -180.0, to: 180.0),
            landingLatitude: Faker::Number.between(from: -90.0, to: 90.0),
            landingLongitude: Faker::Number.between(from: -180.0, to: 180.0),
            takeOffTime: "2023-01-02T01:00:00Z", #飛行時間が重複
            landingTime: "2023-01-02T02:00:00Z"
          },
          {
            droneRegistrationId: drone_registration_id,
            pilotId: "PL#{Faker::Number.number(digits: 11)}",
            takeOffLatitude: Faker::Number.between(from: -90.0, to: 90.0),
            takeOffLongitude: Faker::Number.between(from: -180.0, to: 180.0),
            landingLatitude: Faker::Number.between(from: -90.0, to: 90.0),
            landingLongitude: Faker::Number.between(from: -180.0, to: 180.0),
            takeOffTime: "2023-01-02T01:30:00Z", #飛行時間が重複
            landingTime: "2023-01-02T02:30:00Z"
          }
        ]
      end

      it 'does not create flights with overlapping times and returns status :unprocessable_entity' do
        post '/flights', params: overlapping_flight_data.to_json, headers: @auth_headers.merge({'CONTENT_TYPE' => 'application/json'})

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("同じドローンIDで重複した時間帯での飛行が検出されました。")
      end
    end

    # 正しく登録できない場合_2：
    # パイロットIDが指定されたフォーマットに違反している場合
    context 'when pilot_id format is invalid' do
      let(:invalid_pilot_id_data) do
        [{
          droneRegistrationId: FactoryBot.create(:drone).drone_registration_id,
          pilotId: "ABC",
          takeOffLatitude: "35.787671",
          takeOffLongitude: "137.797908",
          landingLatitude: "35.787671",
          landingLongitude: "137.797908",
          takeOffTime: "2023-01-02T00:00:00Z",
          landingTime: "2023-01-02T01:00:00Z"
        }].to_json
      end

      it 'returns status :unprocessable_entity for invalid pilot ID format' do
        post '/flights', params: invalid_pilot_id_data, headers: @auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end

    # 正しく登録できない場合_3：
    # 離陸日時が着陸日時より後の場合
    context 'when take_off_time is after landing_time' do
      let(:invalid_time_data) do
        [{
          droneRegistrationId: FactoryBot.create(:drone).drone_registration_id,
          pilotId: "PL#{Faker::Number.number(digits: 11)}",
          takeOffLatitude: "35.787671",
          takeOffLongitude: "137.797908",
          landingLatitude: "35.787671",
          landingLongitude: "137.797908",
          takeOffTime: "2023-01-02T02:00:00Z",
          landingTime: "2023-01-02T01:00:00Z"
        }].to_json
      end

      it 'returns status :unprocessable_entity when take_off_time is after landing_time' do
        post '/flights', params: invalid_time_data, headers: @auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end

    # 正しく登録できない場合_4：
    # -90 <= 緯度 <= 90, -180 <= 経度 <= 180の範囲を超えた場合
    context 'when latitude or longitude is out of valid range' do
      let(:invalid_location_data) do
        [{
          droneRegistrationId: FactoryBot.create(:drone).drone_registration_id,
          pilotId: "PL#{Faker::Number.number(digits: 11)}",
          takeOffLatitude: 91,
          takeOffLongitude: 181,
          landingLatitude: -92,
          landingLongitude: -181,
          takeOffTime: "2023-01-02T02:00:00Z",
          landingTime: "2023-01-02T01:00:00Z"
        }].to_json
      end

      it 'returns status :unprocessable_entity for latitude or longitude out of range' do
        post '/flights', params: invalid_location_data, headers: @auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe 'GET #index' do
    let!(:drone) { create(:drone) }
    before do
      create(:flight, drone: drone, take_off_time: "2023-01-01T08:00:00Z", landing_time: "2023-01-01T09:00:00Z")
      create(:flight, drone: drone, take_off_time: "2023-01-01T10:00:00Z", landing_time: "2023-01-01T11:00:00Z")
      create(:flight, drone: drone, take_off_time: "2023-01-01T12:00:00Z", landing_time: "2023-01-01T13:00:00Z")
      # Basic認証の設定
      user = ENV["BASIC_AUTH_USERNAME"]
      password = ENV["BASIC_AUTH_PASSWORD"]
      @auth_headers = { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user,password) }
    end
    
    # 正しく正規データ請求できる場合_1：
    # 入力したdroneのIDが存在する
    context 'when the drone exists' do
      it 'returns all flights for a given drone' do
        get "/flights", params: { drone_registration_id: drone.drone_registration_id }, headers: @auth_headers.merge({'CONTENT_TYPE' => 'application/json'})

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["drone_registration_id"]).to eq(drone.drone_registration_id)
        expect(json_response["flights"].size).to eq(3) # 3つのフライトがあることを確認
        expect(json_response).to have_key("total_flight_time") # 総飛行時間が含まれていることを確認
      end
    end

    # 正規データ請求できない場合_2：
    # 入力したdroneのIDが存在しない
    context 'when the drone does not exist' do
      it 'returns a not found message' do
        get "/flights", params: { drone_registration_id: "nonexistent" }, headers: @auth_headers.merge({'CONTENT_TYPE' => 'application/json'})

        expect(response).to have_http_status(:not_found), headers: @auth_headers.merge({'CONTENT_TYPE' => 'application/json'})
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("指定したドローンは見つかりませんでした。")
      end
    end
  end
end
