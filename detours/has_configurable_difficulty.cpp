/**
 * vim: set ts=4 :
 * =============================================================================
 * Left 4 Downtown SourceMod Extension
 * Copyright (C) 2010 Michael "ProdigySim" Busby
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#include "has_configurable_difficulty.h"
#include "extension.h"

namespace Detours
{
	int HasConfigurableDifficulty::OnHasConfigurableDifficulty()
	{
		//L4D_DEBUG_LOG("HasConfigurableDifficulty() has been called");

		cell_t result = Pl_Continue;

		int actualInvocationResult = (this->*(GetTrampoline()))();

		int overrideValue = actualInvocationResult;
		
		if(g_pFwdOnHasConfigurableDifficulty)
		{
			//L4D_DEBUG_LOG("L4D_OnHasConfigurableDifficulty(return %d) forward has been sent out", target);
			g_pFwdOnHasConfigurableDifficulty->PushCellByRef(&overrideValue);
			g_pFwdOnHasConfigurableDifficulty->Execute(&result);
		}

		if(result == Pl_Handled)
		{
			//L4D_DEBUG_LOG("CTerrorGameRules::HasConfigurableDifficulty() return value overriden with %d", overrideValue);
			return overrideValue;
		}
		else
		{
			return actualInvocationResult;
		}
	}
};
