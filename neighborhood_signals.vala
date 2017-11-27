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
using TaskletSystem;

namespace Netsukuku
{
    void neighborhood_nic_address_set(string my_dev, string my_addr)
    {
        if (identity_mgr != null)
        {
            print(@"Warning: Signal `nic_address_set($(my_dev),$(my_addr))` when module Identities is already initialized.\n");
            print(@"         This should not happen and will be ignored.\n");
            return;
        }
        string my_mac = macgetter.get_mac(my_dev).up();
        HandledNic n = new HandledNic();
        n.dev = my_dev;
        n.mac = my_mac;
        n.linklocal = my_addr;
        handlednic_list.add(n);
    }

    void neighborhood_arc_added(INeighborhoodArc arc)
    {
        // Add arc to identity_manager
        Arc _arc = new Arc();
        _arc.neighborhood_arc = arc;
        _arc.idmgmt_arc = new IdmgmtArc(_arc);
        arc_list.add(_arc);
        identity_mgr.add_arc(_arc.idmgmt_arc);
    }

    void neighborhood_arc_changed(INeighborhoodArc arc)
    {
        // TODO if qspn_arc is present, change cost
    }

    void neighborhood_arc_removing(INeighborhoodArc arc, bool is_still_usable)
    {
        // Remove arc from identity_manager
        Arc? to_del = null;
        foreach (Arc _a in arc_list) if (_a.neighborhood_arc == arc) {to_del = _a; break;}
        if (to_del == null) return;
        identity_mgr.remove_arc(to_del.idmgmt_arc);
    }

    void neighborhood_arc_removed(INeighborhoodArc arc)
    {
        // TODO ?
    }

    void neighborhood_nic_address_unset(string my_dev, string my_addr)
    {
        // TODO remove from handlednics
    }
}