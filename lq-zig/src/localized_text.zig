//! localized_text.qc -- Centralized location for text that can be printed out
//! during gameplay (the `__LIBREQUAKE__` versions). Use with `S(...)`, or
//! `S(LOC_X ++ "...")` where the original juxtaposes string literals.

// Copyright (C) 1996-1997  Id Software, Inc.
// Copyright (C) 2023 ZungryWare <zungrysoftentertainment@gmail.com>
// Copyright (C) 2024 Ivy Bowling <motolegacy@proton.me>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
// See file, 'COPYING', for details.

//
// localized_text.qc -- Centralized location for text that can be printed out
// during gameplay. Formerly localization.qc
//

// EPISODE EPILOGUE STRINGS
// These strings in-engine have a 40 character limit before
// truncation.

pub const LOC_EPILOGUE_0 = "\nAs the ethereal essence of your very\nbeing drifts through time and space,\nyou experience relentless calm and\nserene determination. You embrace the\nliminal, formless nature of your\nexistence within the amorphous expanse\nbetween realities.\n\nSuspended between the veils of life\nand death, among the realm of celestial\ndissolution, you wait to be called upon\nagain. To regain your corporeal form\nand step into the crucible of fate.\nTo finish your task and keep at bay the\nonslaught of cosmic horrors.\n";
pub const LOC_EPILOGUE_1 = "Congratulations! You have beaten Episode 1 of LibreQuake!";
pub const LOC_EPILOGUE_1_FREEWARE = LOC_EPILOGUE_1;
pub const LOC_EPILOGUE_2 = "Congratulations! You have beaten Episode 2 of LibreQuake!";
pub const LOC_EPILOGUE_3 = "Congratulations! You have beaten Episode 3 of LibreQuake!";
pub const LOC_EPILOGUE_4 = "Congratulations! You have beaten Episode 4 of LibreQuake!";
pub const LOC_EPILOGUE_RUNES = "You have collected all of the runes and may advance to the final map!";
pub const LOC_EPILOGUE_FINALE = "Thanks for playing the beta version of LibreQuake!";

// CLIENT & SERVER STATE STRINGS

pub const LOC_CLIENT_JOIN = " joined the server";
pub const LOC_CLIENT_EXIT_LEVEL = " exited the level";
pub const LOC_CLIENT_DISCON_A = " left the server the game with ";
pub const LOC_CLIENT_DISCON_B = " frags";

// CLIENT WEAPON STATUS STRINGS

pub const LOC_WEAPON_INVALID = "Invalid weapon";
pub const LOC_WEAPON_NOAMMO = "Out of ammo";

// CLIENT ITEM COLLECTION STRINGS

pub const LOC_ITEM_PICKUP_NORMAL = "You got ";
pub const LOC_ITEM_PICKUP_HEALTH = "You receieve ";
pub const LOC_ITEM_PICKUP_ADD_HEALTH = " additional health";

pub const LOC_ITEM_FROM_BACKPACK = " from a backpack"; // Unused..

pub const LOC_ITEM_TYPE_HEALTH = " health";
pub const LOC_ITEM_TYPE_ARMOR = " armor";

pub const LOC_ITEM_NAME_QUADDMG = "the Crusher Sigil";
pub const LOC_ITEM_NAME_OCTDMG = "the Demolisher Sigil";
pub const LOC_ITEM_NAME_PENTPROT = "Lucifier's Protection";
pub const LOC_ITEM_NAME_SHADRING = "the Eye of Enigma";
pub const LOC_ITEM_NAME_BIOSUIT = "the Diving Suit";
pub const LOC_ITEM_NAME_BACKPACK = "Backpack";

pub const LOC_ITEM_FADE_QUADDMG = "Your Crusher Sigil is fading...";
pub const LOC_ITEM_FADE_OCTDMG = "Your Demolisher Sigil is fading...";
pub const LOC_ITEM_FADE_PENTPROT = "Lucifier's Protection is fading...";
pub const LOC_ITEM_FADE_SHADRING = "The Eye of Enigma is fading...";
pub const LOC_ITEM_FADE_BIOSUIT = "Air in Diving Suit is running out...";

pub const LOC_BONUS_POWERS = " is coming for you all!!!";

pub const LOC_ITEM_LOST_A = " lost ";
pub const LOC_ITEM_LOST_B = " with ";
pub const LOC_ITEM_LOST_C = " seconds left";

// WEAPON AND AMMO STRINGS

pub const LOC_WEAPON_NAME_AXE = "Axe"; // Unused..
pub const LOC_WEAPON_NAME_SHOTGUN = "Shotgun"; // Unused..
pub const LOC_WEAPON_NAME_SUPER_SHOTGUN = "Double-Barreled Shotgun";
pub const LOC_WEAPON_NAME_NAILGUN = "Nailgun";
pub const LOC_WEAPON_NAME_SUPER_NAILGUN = "Super Nailgun";
pub const LOC_WEAPON_NAME_GRENADE_LAUNCH = "Grenade Launcher";
pub const LOC_WEAPON_NAME_ROCKET_LAUNCH = "Rocket Launcher";
pub const LOC_WEAPON_NAME_THUNDERBOLT = "Lightning Gun";

pub const LOC_WEAPON_AMMO_SHELLS = "shells";
pub const LOC_WEAPON_AMMO_NAILS = "nails";
pub const LOC_WEAPON_AMMO_ROCKETS = "rockets";
pub const LOC_WEAPON_AMMO_CELLS = "cells";

// KEY STRINGS

pub const LOC_KEY_NAME_SILVER = "Silver Key";
pub const LOC_KEY_NAME_SILVER_RUNE = "Silver Key";
pub const LOC_KEY_NAME_SILVER_CARD = "Silver Keycard";
pub const LOC_KEY_NAME_GOLD = "Gold Key";
pub const LOC_KEY_NAME_GOLD_RUNE = "Gold Key";
pub const LOC_KEY_NAME_GOLD_CARD = "Gold Keycard";
pub const LOC_KEY_NEED = "You need ";

// MISC STRINGS

pub const LOC_COUNTER_COUNT_1A = "Only ";
pub const LOC_COUNTER_COUNT_1B = " more to go...";
pub const LOC_COUNTER_COUNT_2 = "There are more to go...";
pub const LOC_COUNTER_COMPLETE = "Sequence completed!";

pub const LOC_SECRET = "You found a secret!";

// RUNE STRINGS

pub const LOC_RUNE_GET = "You got the rune!";

pub const LOC_RUNE_LQ_YOU = "You";
pub const LOC_RUNE_LQ_BLOOD = " got the Rune of Blood!";
pub const LOC_RUNE_LQ_BONE = " got the Rune of Bone!";
pub const LOC_RUNE_LQ_MIND = " got the Rune of Mind!";
pub const LOC_RUNE_LQ_SOUL = " got the Rune of Soul!";

// CLIENT DEATH TO MONSTER STRINGS

pub const LOC_DEATH_ARMY = " was shot by a Chosen";
pub const LOC_DEATH_ENFORCER = " was mowed down by a Cyberhunter";
pub const LOC_DEATH_DOG = " was gored by a Gore Hound";
pub const LOC_DEATH_OGRE = " was demolished by a Barrel Fang";
pub const LOC_DEATH_DEMON1 = " was disemboweled by a Moon Rat";
pub const LOC_DEATH_WIZARD = " was shot by a Messenger";
pub const LOC_DEATH_ZOMBIE = " was pelted by a Deathless Cultist";
pub const LOC_DEATH_KNIGHT = " was stabbed by a Carcosan Knight";
pub const LOC_DEATH_HELL_KNIGHT = " was gutted by a Biohell Warrior";
pub const LOC_DEATH_FISH = " was nibbled by a Spine Eel";
pub const LOC_DEATH_SHAMBLER = " was shredded by a Hollow";
pub const LOC_DEATH_SHALRATH = " was blasted by a Servant of Nyarlathotep";
pub const LOC_DEATH_TARBABY = " was swarmed by a Bog Face";
pub const LOC_DEATH_BOSS = " was obliterated by Cthulhi";
pub const LOC_DEATH_OLDONE = " became one with Shoggoth";

// CLIENT DEATH TO ENVIRONMENT STRINGS

pub const LOC_DEATH_EXPLO_BOX = " was sent sky high";
pub const LOC_DEATH_SQUISH = " was crushed";
pub const LOC_DEATH_SQUISH2 = " was crushed by ";
pub const LOC_DEATH_TRAP_SPIKE = " was perforated";
pub const LOC_DEATH_TRAP_LASER = " was lasered";
pub const LOC_DEATH_FIREBALL = " was hit by a lavaball";
pub const LOC_DEATH_LEAVE = " tried to escape";
pub const LOC_DEATH_DROWN1 = " forgot how to swim";
pub const LOC_DEATH_DROWN2 = " ran out of air";
pub const LOC_DEATH_SLIME1 = " dissolved in acid";
pub const LOC_DEATH_SLIME2 = " was disincorporated";
pub const LOC_DEATH_LAVA1 = " fell into lava";
pub const LOC_DEATH_LAVA2 = " combusted";
pub const LOC_DEATH_LAVA3 = " dove headfirst into hot lava";
pub const LOC_DEATH_FALL1 = " fell off a cliff";
pub const LOC_DEATH_FALL2 = " took a long walk off a short pier";
pub const LOC_DEATH_SPACE1 = " fell into space";
pub const LOC_DEATH_SPACE2 = "'s screams went unheard";
pub const LOC_DEATH_VOID1 = " fell into the void";
pub const LOC_DEATH_VOID2 = " fell out of existence";
pub const LOC_DEATH_DISCHARGE_WATER = " took a toaster bath";
pub const LOC_DEATH_DISCHARGE_SLIME = " took a toaster bath";
pub const LOC_DEATH_DISCHARGE_LAVA = " took a toaster bath";
pub const LOC_DEATH_DISCHARGE_SELF = "'s Lightning Gun Malfunctioned";
pub const LOC_DEATH_SELF_GRENADE = " didn't launch the grenade far enough";
pub const LOC_DEATH_SELF_ROCKET = " played with explosives";
pub const LOC_DEATH_SELF_OTHER = " misfired";
pub const LOC_DEATH_SUICIDE = " committed suicide";
pub const LOC_DEATH_OTHER = " died";

// CLIENT DEATH TO CLIENT STRINGS

// Deathstring 1 is the standard one
// Deathstring 2 has a 1/100 chance to be used instead
// Deathstring G is used for when the victim was gibbed (Grenade Launcher and Rocket Launcher only)
// Deathstring Q is used if the attacker had a Quad Damage
// Deathstring D1 is used if the attack was a discharge (Lightning Gun only)
// Deathstring D2 has a 1/100 chance to be used instead (Lightning Gun only)
// The format for printing is: victim name, deathstring A, attacker name, deathstring B

pub const LOC_DEATH_AXE_1A = " was hacked to death by ";
pub const LOC_DEATH_AXE_1B = "";
pub const LOC_DEATH_AXE_2A = " was chopped to bits by ";
pub const LOC_DEATH_AXE_2B = "";
pub const LOC_DEATH_AXE_QA = "'s bucket was kicked by ";
pub const LOC_DEATH_AXE_QB = "";

pub const LOC_DEATH_SHOTGUN_1A = " sucked on ";
pub const LOC_DEATH_SHOTGUN_1B = "'s muffler";
pub const LOC_DEATH_SHOTGUN_2A = " nibbled on ";
pub const LOC_DEATH_SHOTGUN_2B = "'s muffler";
pub const LOC_DEATH_SHOTGUN_QA = " was put six feet under by ";
pub const LOC_DEATH_SHOTGUN_QB = "";

pub const LOC_DEATH_SUPER_SHOTGUN_1A = " was blasted by ";
pub const LOC_DEATH_SUPER_SHOTGUN_1B = "";
pub const LOC_DEATH_SUPER_SHOTGUN_2A = " was shredded by ";
pub const LOC_DEATH_SUPER_SHOTGUN_2B = "";
pub const LOC_DEATH_SUPER_SHOTGUN_QA = " was sent home in a box by ";
pub const LOC_DEATH_SUPER_SHOTGUN_QB = "";

pub const LOC_DEATH_NAILGUN_1A = " was pierced by ";
pub const LOC_DEATH_NAILGUN_1B = "";
pub const LOC_DEATH_NAILGUN_2A = " was filled with holes by ";
pub const LOC_DEATH_NAILGUN_2B = "";
pub const LOC_DEATH_NAILGUN_QA = "'s mortal coil was shuffled off by ";
pub const LOC_DEATH_NAILGUN_QB = "";

pub const LOC_DEATH_SUPER_NAILGUN_1A = " was perforated by ";
pub const LOC_DEATH_SUPER_NAILGUN_1B = "";
pub const LOC_DEATH_SUPER_NAILGUN_2A = " was given speed holes by ";
pub const LOC_DEATH_SUPER_NAILGUN_2B = "";
pub const LOC_DEATH_SUPER_NAILGUN_QA = "'s chips were cashed by ";
pub const LOC_DEATH_SUPER_NAILGUN_QB = "";

pub const LOC_DEATH_GRENADE_LAUNCHER_1A = " tripped over ";
pub const LOC_DEATH_GRENADE_LAUNCHER_1B = "'s grenade";
pub const LOC_DEATH_GRENADE_LAUNCHER_2A = " stepped on ";
pub const LOC_DEATH_GRENADE_LAUNCHER_2B = "'s grenade";
pub const LOC_DEATH_GRENADE_LAUNCHER_GA = " was gibbed by ";
pub const LOC_DEATH_GRENADE_LAUNCHER_GB = "'s grenade";
pub const LOC_DEATH_GRENADE_LAUNCHER_QA = "'s clock was cleaned by ";
pub const LOC_DEATH_GRENADE_LAUNCHER_QB = "";

pub const LOC_DEATH_ROCKET_LAUNCHER_1A = " was blasted by ";
pub const LOC_DEATH_ROCKET_LAUNCHER_1B = "'s rocket";
pub const LOC_DEATH_ROCKET_LAUNCHER_2A = " was fulminated by ";
pub const LOC_DEATH_ROCKET_LAUNCHER_2B = "'s rocket";
pub const LOC_DEATH_ROCKET_LAUNCHER_GA = " was gibbed by ";
pub const LOC_DEATH_ROCKET_LAUNCHER_GB = "'s rocket";
pub const LOC_DEATH_ROCKET_LAUNCHER_Q1A = " rode ";
pub const LOC_DEATH_ROCKET_LAUNCHER_Q1B = "'s pale horse";

pub const LOC_DEATH_LIGHTNING_1A = " was electrocuted by ";
pub const LOC_DEATH_LIGHTNING_1B = "";
pub const LOC_DEATH_LIGHTNING_2A = " was given shock treatment by ";
pub const LOC_DEATH_LIGHTNING_2B = "";
pub const LOC_DEATH_LIGHTNING_QA = " was sent beyond the veil by ";
pub const LOC_DEATH_LIGHTNING_QB = "";
pub const LOC_DEATH_LIGHTNING_DA = " was given a toaster bath by ";
pub const LOC_DEATH_LIGHTNING_DB = "";

pub const LOC_DEATH_TELEFRAG = " was telefragged by ";

pub const LOC_DEATH_DEFLECT_A = "Lucifer's Protection deflected ";
pub const LOC_DEATH_DEFLECT_B = "'s telefrag on ";

pub const LOC_TEAMKILL_1 = " killed a teammate";
pub const LOC_TEAMKILL_2 = " friendly-fired";
pub const LOC_TEAMKILL_3 = " needs an eye exam";
pub const LOC_TEAMKILL_4 = " betrayed their friend";
pub const LOC_TEAMKILL_SQUISH = " crushed a teammate";

pub const LOC_DEATH_KILL = " killed ";

// LIBREQUAKE UTILITY STRINGS

pub const LOC_LQ_ISDEVELOPER = "You must be a developer!";

// LIBREQUAKE CAMERA STRINGS

pub const LOC_LQ_CAMERAS_MAX = "You have too many cameras!";
pub const LOC_LQ_CAMERA_SPAWN_A = "Camera placed successfully, ";
pub const LOC_LQ_CAMERA_SPAWN_B = " remaining";
pub const LOC_LQ_CAMERA_TIME_A = "Time between cameras changed to ";
pub const LOC_LQ_CAMERA_TIME_B = " seconds";
pub const LOC_LQ_CAMERA_NONE = "Oh noes! No camera found! :(";
