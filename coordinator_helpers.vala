/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2018 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
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
using Netsukuku.Coordinator;
using TaskletSystem;

namespace Netsukuku
{
    class CoordinatorEvaluateEnterHandler : Object, IEvaluateEnterHandler
    {
        public CoordinatorEvaluateEnterHandler(IdentityData identity_data)
        {
            this.identity_data = identity_data;
        }
        private weak IdentityData identity_data;

        public Object evaluate_enter(int lvl, Object evaluate_enter_data)
        throws HandlingImpossibleError
        {
            error("not implemented yet");
        }
    }

    class CoordinatorBeginEnterHandler : Object, IBeginEnterHandler
    {
        public CoordinatorBeginEnterHandler(IdentityData identity_data)
        {
            this.identity_data = identity_data;
        }
        private weak IdentityData identity_data;

        public Object begin_enter(int lvl, Object begin_enter_data)
        throws HandlingImpossibleError
        {
            error("not implemented yet");
        }
    }

    class CoordinatorCompletedEnterHandler : Object, ICompletedEnterHandler
    {
        public CoordinatorCompletedEnterHandler(IdentityData identity_data)
        {
            this.identity_data = identity_data;
        }
        private weak IdentityData identity_data;

        public Object completed_enter(int lvl, Object completed_enter_data)
        throws HandlingImpossibleError
        {
            error("not implemented yet");
        }
    }

    class CoordinatorAbortEnterHandler : Object, IAbortEnterHandler
    {
        public CoordinatorAbortEnterHandler(IdentityData identity_data)
        {
            this.identity_data = identity_data;
        }
        private weak IdentityData identity_data;

        public Object abort_enter(int lvl, Object abort_enter_data)
        throws HandlingImpossibleError
        {
            error("not implemented yet");
        }
    }

    class CoordinatorPropagationHandler : Object, IPropagationHandler
    {
        public CoordinatorPropagationHandler(IdentityData identity_data)
        {
            this.identity_data = identity_data;
        }
        private weak IdentityData identity_data;

        public void finish_migration(int lvl, Object finish_migration_data)
        {
            error("not implemented yet");
        }

        public void prepare_migration(int lvl, Object prepare_migration_data)
        {
            error("not implemented yet");
        }

        public void we_have_splitted(int lvl, Object we_have_splitted_data)
        {
            error("not implemented yet");
        }
    }

    class CoordinatorMap : Object, ICoordinatorMap
    {
        public CoordinatorMap(IdentityData identity_data)
        {
            this.identity_data = identity_data;
        }
        private weak IdentityData identity_data;

        public int get_my_pos(int lvl)
        {
            return identity_data.my_naddr.pos[lvl];
        }

        public Gee.List<int> get_free_pos(int lvl)
        {
            try {
                Gee.List<HCoord> busy = identity_data.qspn_mgr.get_known_destinations(lvl);
                Gee.List<int> ret = new ArrayList<int>();
                for (int i = 0; i < gsizes[lvl]; i++) ret.add(i);
                foreach (HCoord hc in busy) ret.remove(hc.pos);
                return ret;
            } catch (QspnBootstrapInProgressError e) {
                assert_not_reached();
            }
        }

        public int get_n_nodes()
        {
            try {
                return identity_data.qspn_mgr.get_nodes_inside(levels);
            } catch (QspnBootstrapInProgressError e) {
                assert_not_reached();
            }
        }

        public int64 get_fp_id(int lvl)
        {
            try {
                Fingerprint fp = (Fingerprint)identity_data.qspn_mgr.get_fingerprint(lvl);
                return fp.id;
            } catch (QspnBootstrapInProgressError e) {
                assert_not_reached();
            }
        }
    }

    class CoordinatorStubFactory : Object, IStubFactory
    {
        public CoordinatorStubFactory(IdentityData identity_data)
        {
            this.identity_data = identity_data;
        }
        private weak IdentityData identity_data;

        public ICoordinatorManagerStub get_stub_for_all_neighbors()
        {
            error("not implemented yet");
        }

        public Gee.List<ICoordinatorManagerStub> get_stub_for_each_neighbor()
        {
            error("not implemented yet");
        }
    }
}
