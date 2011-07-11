# -------------------------------------------------------------------------- #
# Copyright 2002-2011, OpenNebula Project Leads (OpenNebula.org)             #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

require 'one_helper'

class OneAclHelper < OpenNebulaHelper::OneHelper
    def self.rname
        "ACL"
    end

    def self.conf_file
        "oneacl.yaml"
    end

private

    def factory(id = nil)
        if id
            OpenNebula::Acl.new_with_id(id, @client)
        else
            xml = OpenNebula::Acl.build_xml
            OpenNebula::Acl.new(xml, @client)
        end
    end

    def factory_pool(filter)
        OpenNebula::AclPool.new(@client)
    end

    # TODO check that @content[:resources_str]  is valid
    def self.resource_mask(str)
        resource_type=str.split("/")[0]

        mask = "-------"

        resource_type.split("+").each{|type|
            case type
                when "VM"
                    mask[0] = "V"
                when "HOST"
                    mask[1] = "H"
                when "NET"
                    mask[2] = "N"
                when "IMAGE"
                    mask[3] = "I"
                when "USER"
                    mask[4] = "U"
                when "TEMPLATE"
                    mask[5] = "T"
                when "GROUP"
                    mask[6] = "G"
            end
        }
        mask
    end

    # TODO check that @content[:resources_str]  is valid
    def self.right_mask(str)
        mask = "---------"

        str.split("+").each{|type|
            case type
                when "CREATE"
                    mask[0] = "C"
                when "DELETE"
                    mask[1] = "D"
                when "USE"
                    mask[2] = "U"
                when "MANAGE"
                    mask[3] = "M"
                when "INFO"
                    mask[4] = "I"
                when "INFO_POOL"
                    mask[5] = "P"
                when "INFO_POOL_MINE"
                    mask[6] = "p"
                when "INSTANTIATE"
                    mask[7] = "T"
                when "CHOWN"
                    mask[8] = "W"
            end
        }

        mask
    end

    def format_pool(pool, options, top=false)
        config_file=self.class.table_conf

        table=CLIHelper::ShowTable.new(config_file, self) do
            column :ID, "Rule Identifier",
                          :size=>5 do |d|
                d['ID']
            end

            column :USER, "To which resource owner the rule applies to",
                          :size=>8 do |d|
                d['STRING'].split(" ")[0]
            end

            column :RES_VHNIUTG, "Resource to which the rule applies" do |d|
               OneAclHelper::resource_mask d['STRING'].split(" ")[1]
            end

            column :RID, "Resource ID", :right, :size=>8 do |d|
                d['STRING'].split(" ")[1].split("/")[1]
            end

            column :OPE_CDUMIPpTW,
                    "Operation to which the rule applies" do |d|
                OneAclHelper::right_mask d['STRING'].split(" ")[2]
            end

            default :ID, :USER, :RES_VHNIUTG, :RID, :OPE_CDUMIPpTW
        end

        table.show(pool, options)

    end

end