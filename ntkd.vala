/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2017 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
 *
 *  Netsukuku is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Netsukuku is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Netsukuku.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;
using Netsukuku;
using Netsukuku.Neighborhood;
using Netsukuku.Identities;
using Netsukuku.Qspn;
using Netsukuku.Coordinator;
using Netsukuku.Hooking;
using Netsukuku.Andna;
using TaskletSystem;

namespace Netsukuku
{
    const uint16 ntkd_port = 60269;
    const int max_paths = 5;
    const double max_common_hops_ratio = 0.6;
    const int arc_timeout = 10000;

    [CCode (array_length = false, array_null_terminated = true)]
    string[] interfaces;
    bool accept_anonymous_requests;
    bool no_anonymize;
    int subnetlevel;

    ITasklet tasklet;
    Commander cm;
    TableNames tn;
    ArrayList<int> gsizes;
    ArrayList<int> g_exp;
    int levels;
    NeighborhoodManager? neighborhood_mgr;
    IdentityManager? identity_mgr;
    ArrayList<HandledNic> handlednic_list;
    ArrayList<IdmgmtArc> arc_list;
    ArrayList<IdentityData> local_identities;

    IdentityData find_or_create_local_identity(NodeID node_id)
    {
        foreach (IdentityData k in local_identities)
        {
            if (k.nodeid.equals(node_id))
            {
                return k;
            }
        }
        IdentityData ret = new IdentityData(node_id);
        local_identities.add(ret);
        return ret;
    }

    void remove_local_identity(NodeID node_id)
    {
        local_identities.remove(find_or_create_local_identity(node_id));
    }

    IdentityArc find_identity_arc(IdentityData identity_data, IIdmgmtArc arc, NodeID peer_nodeid)
    {
        foreach (IdentityArc ia in identity_data.identity_arcs)
        {
            if (ia.arc == arc)
             if (ia.id_arc.get_peer_nodeid().equals(peer_nodeid))
                return ia;
        }
        error("IdentityArc not found");
    }

    ServerDelegate dlg;
    ServerErrorHandler err;
    ITaskletHandle t_tcp;
    ArrayList<ITaskletHandle> t_udp_list;

    int main(string[] _args)
    {
        subnetlevel = 0; // default
        accept_anonymous_requests = false; // default
        no_anonymize = false; // default
        OptionContext oc = new OptionContext("<options>");
        OptionEntry[] entries = new OptionEntry[5];
        int index = 0;
        entries[index++] = {"subnetlevel", 's', 0, OptionArg.INT, ref subnetlevel, "Level of g-node for autonomous subnet", null};
        entries[index++] = {"interfaces", 'i', 0, OptionArg.STRING_ARRAY, ref interfaces, "Interface (e.g. -i eth1). You can use it multiple times.", null};
        entries[index++] = {"serve-anonymous", 'k', 0, OptionArg.NONE, ref accept_anonymous_requests, "Accept anonymous requests", null};
        entries[index++] = {"no-anonymize", 'j', 0, OptionArg.NONE, ref no_anonymize, "Disable anonymizer", null};
        entries[index++] = { null };
        oc.add_main_entries(entries, null);
        try {
            oc.parse(ref _args);
        }
        catch (OptionError e) {
            print(@"Error parsing options: $(e.message)\n");
            return 1;
        }

        ArrayList<string> args = new ArrayList<string>.wrap(_args);
        ArrayList<int> naddr;
        ArrayList<string> devs;
        string ntklocalhost;

        configuration(ref args, out naddr, out devs);

        startup(ref naddr, ref devs, out ntklocalhost);

        mainloop();

        cleanup(ref ntklocalhost);

        return 0;
    }

    bool do_me_exit = false;
    void safe_exit(int sig)
    {
        // We got here because of a signal. Quick processing.
        do_me_exit = true;
    }

    class HandledNic : Object
    {
        public string dev;
        public string mac;
        public string linklocal;
    }

    class IdentityData : Object
    {
        public IdentityData(NodeID nodeid)
        {
            this.nodeid = nodeid;
            identity_arcs = new ArrayList<IdentityArc>();
            connectivity_from_level = 0;
            connectivity_to_level = 0;
        }

        public NodeID nodeid;
        public int connectivity_from_level;
        public int connectivity_to_level;
        public AddressManagerForIdentity addr_man;

        public ArrayList<IdentityArc> identity_arcs;

        private string _network_namespace;
        public string network_namespace {
            get {
                _network_namespace = identity_mgr.get_namespace(nodeid);
                return _network_namespace;
            }
        }

        public bool main_id {
            get {
                return nodeid.equals(identity_mgr.get_main_id());
            }
        }

    }

    class IdentityArc : Object
    {
        public IIdmgmtArc arc;
        public NodeID id;
        public IIdmgmtIdentityArc id_arc;
        public weak IdentityData identity_data;
        public string peer_mac;
        public string peer_linklocal;

        public string? prev_peer_mac;
        public string? prev_peer_linklocal;

        public IdentityArc(IdentityData identity_data, IIdmgmtArc arc, IIdmgmtIdentityArc id_arc)
        {
            this.identity_data = identity_data;
            this.arc = arc;
            id = identity_data.nodeid;
            this.id_arc = id_arc;
            peer_mac = id_arc.get_peer_mac();
            peer_linklocal = id_arc.get_peer_linklocal();

            prev_peer_mac = null;
            prev_peer_linklocal = null;
        }
    }
}

