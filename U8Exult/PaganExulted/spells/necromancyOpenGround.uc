//necromancyOpenGround.uc
//Placeholder for Open Ground spell (Shape 1087, Frame 0)

void necromancyOpenGround object#() () {
    UI_error_message("necromancyOpenGround executing");

    var caster = item;
    var curMana = caster->get_npc_prop(MANA);
    UI_error_message("Mana before casting: " + curMana);

    // Placeholder mana cost - adjust as needed
    if (curMana < 5) {
        caster->item_say("@Not enough mana...@");
        UI_error_message("Not enough mana to cast Open Ground - return");
        return;
    }

    caster->set_npc_prop(MANA, -5);
    UI_error_message("Begin Animation and Effects");
    caster->item_say("@Des Por Ylem@");

    // Basic animation sequence
    script caster {
        nohalt;
        actor frame CAST_1;
        actor frame CAST_2;
        sfx 67;
        wait 4;
        actor frame STAND;
    }
    UI_error_message("End Animation and Effects");

    // TODO: Add specific spell logic for Open Ground here
    UI_error_message("Placeholder: Open Ground spell effect not implemented");

    // Remove the talisman after successful cast
    item->remove_item();
    UI_error_message("Talisman (Shape 1087, Frame 0) removed");
    
}