import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { FollowWidgetPayload } from '../models/MatchModels'

const STORE = 'team_follow_widget'
const KEY_SNAP = 'widgetSnapshot'
const KEY_FORM_IDS = 'formIds'

export class FollowWidgetStore {
  private static pref: preferences.Preferences | null = null
  private static appCtx: common.Context | null = null

  static async init(context: common.Context): Promise<void> {
    try {
      FollowWidgetStore.appCtx = context.getApplicationContext()
      FollowWidgetStore.pref = await preferences.getPreferences(FollowWidgetStore.appCtx, STORE)
    } catch {
      try {
        FollowWidgetStore.appCtx = context
        FollowWidgetStore.pref = await preferences.getPreferences(context, STORE)
      } catch {
        FollowWidgetStore.pref = null
      }
    }
  }

  static async reload(): Promise<void> {
    if (FollowWidgetStore.appCtx === null) {
      return
    }
    try {
      FollowWidgetStore.pref = await preferences.getPreferences(FollowWidgetStore.appCtx, STORE)
    } catch {
    }
  }

  static emptyPayload(): FollowWidgetPayload {
    return new FollowWidgetPayload()
  }

  static async writeSnapshot(data: FollowWidgetPayload): Promise<void> {
    const raw =
      `{"title":${JSON.stringify(data.title)},"count":${JSON.stringify(data.count)},` +
      `"preview":${JSON.stringify(data.preview)},"status":${JSON.stringify(data.status)}}`
    await FollowWidgetStore.putString(KEY_SNAP, raw)
  }

  static async readSnapshot(context: common.Context): Promise<FollowWidgetPayload> {
    const data = FollowWidgetStore.emptyPayload()
    try {
      let pref = FollowWidgetStore.pref
      if (pref === null) {
        try {
          pref = await preferences.getPreferences(context.getApplicationContext(), STORE)
        } catch {
          pref = await preferences.getPreferences(context, STORE)
        }
      }
      const rawValue = await pref.get(KEY_SNAP, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      if (raw.length === 0) {
        return data
      }
      const parsed = JSON.parse(raw) as FollowWidgetPayload
      if (parsed.title !== undefined && parsed.title.length > 0) {
        data.title = parsed.title
      }
      if (parsed.count !== undefined) {
        data.count = parsed.count
      }
      if (parsed.preview !== undefined && parsed.preview.length > 0) {
        data.preview = parsed.preview
      }
      if (parsed.status !== undefined && parsed.status.length > 0) {
        data.status = parsed.status
      }
    } catch {
    }
    return data
  }

  static async rememberFormId(formId: string): Promise<void> {
    if (formId.length === 0) {
      return
    }
    const ids = await FollowWidgetStore.formIds()
    for (const id of ids) {
      if (id === formId) {
        return
      }
    }
    ids.push(formId)
    await FollowWidgetStore.putString(KEY_FORM_IDS, ids.join(','))
  }

  static async forgetFormId(formId: string): Promise<void> {
    const ids = await FollowWidgetStore.formIds()
    const next: string[] = []
    for (const id of ids) {
      if (id !== formId) {
        next.push(id)
      }
    }
    await FollowWidgetStore.putString(KEY_FORM_IDS, next.join(','))
  }

  static async formIds(): Promise<string[]> {
    if (FollowWidgetStore.pref === null) {
      return []
    }
    try {
      const rawValue = await FollowWidgetStore.pref.get(KEY_FORM_IDS, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      if (raw.length === 0) {
        return []
      }
      return raw.split(',')
    } catch {
      return []
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (FollowWidgetStore.pref === null) {
      return
    }
    try {
      await FollowWidgetStore.pref.put(key, value)
      await FollowWidgetStore.pref.flush()
    } catch {
    }
  }
}
