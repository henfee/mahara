<?php
/**
 * Mahara: Electronic portfolio, weblog, resume builder and social networking
 * Copyright (C) 2006-2008 Catalyst IT Ltd (http://www.catalyst.net.nz)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @package    mahara
 * @subpackage artefact-file
 * @author     Catalyst IT Ltd
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL
 * @copyright  (C) 2006-2008 Catalyst IT Ltd http://catalyst.net.nz
 *
 */

define('INTERNAL', 1);
define('JSON', 1);

require(dirname(dirname(dirname(__FILE__))) . '/init.php');

json_headers();

$artefactid  = param_integer('artefact');    // Artefact being moved
$newparentid = param_integer('newparent');   // Folder to move it to

require_once(get_config('docroot') . 'artefact/lib.php');
$artefact = artefact_instance_from_id($artefactid);

if (!$USER->can_edit_artefact($artefact)) {
    json_reply(true, get_string('movefailednotowner', 'artefact.file'));
}
if (!in_array($artefact->get('artefacttype'), PluginArtefactFile::get_artefact_types())) {
    json_reply(true, get_string('movefailednotfileartefact', 'artefact.file'));
}

if ($newparentid > 0) {
    if ($newparentid == $artefactid) {
        json_reply(true, get_string('movefaileddestinationinartefact', 'artefact.file'));
    }
    if ($newparentid == $artefact->get('parent')) {
        json_reply(false, get_string('filealreadyindestination', 'artefact.file'));
    }
    $newparent = artefact_instance_from_id($newparentid);
    if (!$USER->can_edit_artefact($newparent)) {
        json_reply(true, get_string('movefailednotowner', 'artefact.file'));
    }
    $group = $artefact->get('group');
    if ($group && $group !== $newparent->get('group')) {
        json_reply(true, get_string('movefailednotowner', 'artefact.file'));
    }
    if ($newparent->get('artefacttype') != 'folder') {
        json_reply(true, get_string('movefaileddestinationnotfolder', 'artefact.file'));
    }
    $nextparentid = $newparent->get('parent');
    while (!empty($nextparentid)) {
        if ($nextparentid != $artefactid) {
            $ancestor = artefact_instance_from_id($nextparentid);
            $nextparentid = $ancestor->get('parent');
        } else {
            json_reply(true, get_string('movefaileddestinationinartefact', 'artefact.file'));
        }
    }
} else { // $newparentid === 0
    if ($artefact->get('parent') == null) {
        json_reply(false, get_string('filealreadyindestination', 'artefact.file'));
    }
    $group = $artefact->get('group');
    if ($group) {
        // Use default grouptype artefact permissions to check if the
        // user can move a file to the group's root directory
        require_once(get_config('libroot') . 'group.php');
        $permissions = group_get_default_artefact_permissions($group);
        if (!$permissions[group_user_access($group)]->edit) {
            json_reply(true, get_string('movefailednotowner', 'artefact.file'));
        }
    }
    $newparentid = null;
}

if ($artefact->move($newparentid)) {
    json_reply(false, array('message' => null));
}
json_reply(true, get_string('movefailed', 'artefact.file'));

?>