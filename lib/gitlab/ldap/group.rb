#-------------------------------------------------------------------
#
# Copyright (C) 2013 GitLab.com - Distributed under the MIT Expat License
#
#-------------------------------------------------------------------

module Gitlab
  module LDAP
    class Group
      def initialize(entry)
        @entry = entry
      end

      def name
        entry.cn.join(" ")
      end

      def path
        name.parameterize
      end

      def members
        member_uids.map do |opts|
          adapter.user(opts)
        end.compact
      end

      def member_uids
        if entry.respond_to? :memberuid
          entry.memberuid
        else
          member_dns.map do |dn|
            dn_to_opts(dn)
          end
        end.compact
      end

      private

      def member_dns
        if entry.respond_to? :member
          entry.member
        elsif entry.respond_to? :uniquemember
          entry.uniquemember
        elsif entry.respond_to? :memberof
          entry.memberof
        else
          raise 'Unsupported member attribute'
        end
      end

      def entry
        @entry
      end

      def adapter
        @adapter ||= Gitlab::LDAP::Adapter.new
      end

      def dn_to_opts(dn)
        dn.split(",").first.split("=")
      end
    end
  end
end
