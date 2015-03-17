require "spec_helper"

describe EmsRefresh::Parsers::Foreman do
  let(:date1)   { "2014-11-07T20:41:21Z" }
  let(:parser)  { described_class.new }
  let(:flavors) { {"10" => "110", "20" => "120", "30" => "130"} }
  let(:media)   { {"10" => "210", "20" => "220", "30" => "230"} }
  let(:ptables) { {"10" => "310", "20" => "320", "30" => "330"} }
  let(:locations)     { {"10" => "410", "20" => "420", "30" => "430"} }
  let(:organizations) { {"10" => "510", "20" => "520", "30" => "530"} }
  let(:hostgroups) do
    [
      {
        "id"                 => 8,
        "name"               => "hg8",
        "title"              => "t",
        "operatingsystem_id" => 10,
        "medium_id"          => 20,
        "ptable_id"          => 10,
        "organizations"      => [
          {
            "id" => 10,
          }
        ],
        "locations"          => [
          {
            "id"    => 10,
            "name"  => "l1",
            "title" => "Loc1"
          }, {
            "id"    => 20,
            "name"  => "l2",
            "title" => "Loc1/Loc2"
          }
        ]
      }, {
        "id"                 => 9,
        "name"               => "hg9",
        "description"        => "t",
        "operatingsystem_id" => 20,
        "medium_id"          => 10,
        "ptable_id"          => 30,
        "organizations"      => [
          {
            "id" => 10,
          }
        ],
        "locations"          => [
          {
            "id"    => 10,
            "name"  => "l1",
            "title" => "Loc1"
          }
        ],
      },
    ]
  end
  let(:hosts) do
    [
      {
        "id"                 => 1,
        "name"               => "h1",
        "hostgroup_id"       => 8,
        "operatingsystem_id" => 20,
        "medium_id"          => 10,
        "ptable_id"          => 30,
        "last_compile"       => nil,
        "location_id"        => 10,
        "organization_id"    => 20,
        "build"              => false,
      },
      {
        "id"                 => 2,
        "name"               => "h2",
        "hostgroup_id"       => 9,
        "operatingsystem_id" => 30,
        "medium_id"          => 20,
        "ptable_id"          => 10,
        "last_compile"       => date1,
        "location_id"        => 20,
        "organization_id"    => 10,
        "build"              => true
      },
    ]
  end
  # describe "#provisioning_inv_to_hashes" do
  # end

  describe "#configuration_inv_to_hashes" do
    it "doesnt need provisioning_refresh" do
      result = parser.configuration_inv_to_hashes(
        :operating_system_flavors => flavors,
        :media                    => media,
        :ptables                  => ptables,
        :hostgroups               => hostgroups,
        :hosts                    => hosts,
        :locations                => locations,
        :organizations            => organizations,
      )

      expect(result[:needs_provisioning_refresh]).not_to be_true
    end

    context "without os flavor" do
      it "needs provisioning_refresh" do
        result = parser.configuration_inv_to_hashes(
          :operating_system_flavors => {},
          :media                    => media,
          :ptables                  => ptables,
          :hostgroups               => hostgroups,
          :hosts                    => hosts,
          :locations                => locations,
          :organizations            => organizations,
        )

        expect(result[:needs_provisioning_refresh]).to be_true
      end
    end

    it "sets build state" do
      result = parser.configuration_inv_to_hashes(
        :operating_system_flavors => flavors,
        :media                    => media,
        :ptables                  => ptables,
        :hostgroups               => hostgroups,
        :hosts                    => hosts,
        :locations                => locations,
        :organizations            => organizations,
      )

      expect(result[:configured_systems].first[:build_state]).to be_blank
      expect(result[:configured_systems].last[:build_state]).to eq("pending")
    end

    it "sets last_checkin" do
      result = parser.configuration_inv_to_hashes(
        :operating_system_flavors => flavors,
        :media                    => media,
        :ptables                  => ptables,
        :hostgroups               => hostgroups,
        :hosts                    => hosts,
        :locations                => locations,
        :organizations            => organizations,
      )

      expect(result[:configured_systems].first[:last_checkin]).to be_blank
      expect(result[:configured_systems].last[:last_checkin]).to eq(date1)
    end
  end
end
