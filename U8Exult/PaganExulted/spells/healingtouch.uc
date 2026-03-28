#game "serpentisle"

void healing_touch shape#(0x422) () {
    if (event == DOUBLECLICK) {
        var caster = getOuterContainer(item);
        if (caster->get_npc_prop(MANA) < 5) {
            caster->item_say("@Not enough mana...@");
            return;
        }        
        //struct<ObjPos> target = UI_click_on_item(); //REMOVED DUE TO BUG
        var target = UI_click_on_item();
		caster->halt_scheduled();
        if (target->is_npc()) {
            caster->set_npc_prop(MANA, -5);
            var dir = direction_from(target);
            var str = target->get_npc_prop(STRENGTH);
            var hps = target->get_npc_prop(HEALTH);
            if (hps <= str) {
                script caster {
                    nohalt;
                    face dir;
                    actor frame kneeling;
                    sfx 64;
                    actor frame standing;
                    actor frame reach_1h;
                    actor frame raise_1h;
                    actor frame strike_1h;
                }
                var healquant = UI_die_roll(8, 16);
                var maxheal = str - hps;
                if (healquant > maxheal) {
                    healquant = maxheal;
                }
                target->set_npc_prop(HEALTH, healquant);
            }
        } else {
            caster->item_say("@That is an object...@");
        }
    }
}