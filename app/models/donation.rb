##
# Donate Your Account (donateyouraccount.com)
# Copyright (C) 2011  Kyle Shank (kyle.shank@gmail.com)
# http://www.gnu.org/licenses/agpl.html
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
class Donation < ActiveRecord::Base
  LEVELS = {
      "Bronze" => 1,
      "Silver" => 2,
      "Gold" => 4
  }

  belongs_to :account
  belongs_to :campaign

  has_many :donated_statuses
  has_many :statuses, :through => :donated_statuses

  validates_presence_of :account, :campaign, :level
  validates_uniqueness_of :account_id, :scope =>[:campaign_id]
  validates_inclusion_of :level, :in => [1,2,4]

  scope :with_account, -> {joins(:account)}
  scope :for_campaign, ->(i) {where(campaign_id: i)}
  scope :desc, -> {order("donations.id DESC")}
  scope :gold, -> {where(level: LEVELS["Gold"])}
  scope :silver, -> {where(level: LEVELS["Silver"])}
  scope :bronze, -> {where(level: LEVELS["Bronze"])}
  scope :for_levels, ->(levels) {where(levels.collect{|l| "donations.level = #{l}"}.join(" OR "))}
  scope :for_accounts, ->(accounts) {where(accounts.collect{|a| "donations.account_id=#{a.id}"}.join(" OR ")) }
  scope :active, -> { with_account.where("accounts.expires_at IS NULL or accounts.expires_at > NOW()") }
  scope :group_campaign, -> { with_account.group("donations.campaign_id") }
  scope :twitter, -> { with_account.where(["accounts.type=? and (accounts.expires_at IS NULL or accounts.expires_at > NOW())","TwitterAccount"]) }
  scope :facebook, -> { with_account.where(["accounts.type=? and (accounts.expires_at IS NULL or accounts.expires_at > NOW())","FacebookAccount"]) }
end
