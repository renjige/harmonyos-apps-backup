import fs from 'fs'

const srcPath =
  'E:/huawei001-master/apps/huoli-lvcheng-huoli-jixing/app/entry/build/default/cache/default/default@CompileArkTS/esmodule/release/entry/src/main/ets/services/VitalityStore.ts'
const outPath =
  'E:/huawei001-master/apps/huoli-lvcheng-huoli-jixing/app/entry/src/main/ets/services/VitalityStore.ets'

let s = fs.readFileSync(srcPath, 'utf8')
s = s
  .replace(
    /import preferences from "@ohos:data.preferences";/,
    "import { preferences } from '@kit.ArkData'"
  )
  .replace(
    /import type common from "@ohos:app.ability.common";/,
    "import { common } from '@kit.AbilityKit'"
  )
  .replace(
    /from "@bundle:hljx.pgty.huawei\/entry\/ets\/models\/VitalityModels";/,
    "from '../models/VitalityModels'"
  )
  .replace(
    /from "@bundle:hljx.pgty.huawei\/entry\/ets\/services\/AppContextService";/,
    "from './AppContextService'"
  )
  .replace(/\s*VitalityStore\.notifyDataChanged\(\);\n/g, '\n')
  .replace(/    static notifyDataChanged\(\): void \{[\s\S]*?\n    \}\n/, '')

const pick = `  static async init(context: common.UIAbilityContext): Promise<void> {
    VitalityStore.initAttempted = true
    await VitalityStore.pickPreferences(context)
    VitalityStore.cacheReady = false
    await VitalityStore.hydrateCache()
  }

  static async ensureReady(): Promise<boolean> {
    const ctx = AppContextService.getContext()
    if (VitalityStore.pref === null && ctx !== null) {
      await VitalityStore.pickPreferences(ctx)
    }
    if (VitalityStore.pref !== null && !VitalityStore.cacheReady) {
      await VitalityStore.hydrateCache()
    }
    return VitalityStore.pref !== null || VitalityStore.cacheReady
  }

  private static async pickPreferences(context: common.UIAbilityContext): Promise<void> {
    let abilityPref: preferences.Preferences | null = null
    let appPref: preferences.Preferences | null = null
    try {
      abilityPref = await preferences.getPreferences(context, STORE)
    } catch {
      // ignore
    }
    try {
      appPref = await preferences.getPreferences(context.getApplicationContext(), STORE)
    } catch {
      // ignore
    }
    if (abilityPref === null && appPref === null) {
      VitalityStore.pref = null
      return
    }
    if (abilityPref === null) {
      VitalityStore.pref = appPref
      return
    }
    if (appPref === null) {
      VitalityStore.pref = abilityPref
      return
    }
    const abilityRecords = await VitalityStore.readPrefString(abilityPref, KEY_RECORDS)
    const appRecords = await VitalityStore.readPrefString(appPref, KEY_RECORDS)
    VitalityStore.pref = abilityRecords.length >= appRecords.length ? abilityPref : appPref
    const loser = VitalityStore.pref === abilityPref ? appPref : abilityPref
    const winnerRecords = await VitalityStore.readPrefString(VitalityStore.pref, KEY_RECORDS)
    const loserRecords = await VitalityStore.readPrefString(loser, KEY_RECORDS)
    if (loserRecords.length > winnerRecords.length) {
      await VitalityStore.copyAllKeys(loser, VitalityStore.pref)
    }
  }

  private static async readPrefString(pref: preferences.Preferences, key: string): Promise<string> {
    try {
      const v = await pref.get(key, '')
      return \`\${v}\`
    } catch {
      return ''
    }
  }

  private static async copyAllKeys(from: preferences.Preferences, to: preferences.Preferences): Promise<void> {
    const keys: string[] = [
      KEY_RECORDS, KEY_PROFILE, KEY_ACHIEVEMENTS, KEY_REMINDER_AGENT, KEY_ACTIONS,
      KEY_PINS, KEY_WEEKLY, KEY_NOTES, KEY_SAVED_ACTIONS, KEY_PLANS, KEY_TOPICS
    ]
    for (const key of keys) {
      const value = await VitalityStore.readPrefString(from, key)
      if (value.length > 0) {
        await to.put(key, value)
      }
    }
    try {
      await to.flush()
    } catch {
      // ignore
    }
  }

  private static async openPreferences(context: common.UIAbilityContext): Promise<void> {
    await VitalityStore.pickPreferences(context)
  }
`

s = s.replace(
  /  static async init\(context: common\.UIAbilityContext\): Promise<void> \{[\s\S]*?  private static async openPreferences\(context: common\.UIAbilityContext\): Promise<void> \{[\s\S]*?  \}\n/,
  pick
)

fs.writeFileSync(outPath, s)
console.log('Restored', outPath, 'bytes:', s.length)
