import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { LocalUser } from '../models/XingyuModels'
import { XingyuCodec } from '../models/XingyuModels'

const STORE = 'xingyu_local_auth_v1'

export class LocalAuthStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      LocalAuthStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      LocalAuthStore.pref = null
    }
  }

  static async register(username: string, password: string, realName: string, phone: string): Promise<string> {
    const users = await LocalAuthStore.loadUsers()
    for (const u of users) {
      if (u.username === username) {
        return '账号已存在'
      }
    }
    const nu = new LocalUser()
    nu.username = username
    nu.password = password
    nu.realName = realName
    nu.phone = phone
    users.push(nu)
    await LocalAuthStore.persist(users)
    return ''
  }

  static async verify(username: string, password: string): Promise<boolean> {
    const users = await LocalAuthStore.loadUsers()
    for (const u of users) {
      if (u.username === username && u.password === password) {
        return true
      }
    }
    return false
  }

  static async removeUser(username: string): Promise<void> {
    const users = await LocalAuthStore.loadUsers()
    const next: LocalUser[] = []
    for (const u of users) {
      if (u.username !== username) {
        next.push(u)
      }
    }
    await LocalAuthStore.persist(next)
  }

  private static async loadUsers(): Promise<LocalUser[]> {
    const raw = await LocalAuthStore.getString('users', '')
    const out: LocalUser[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const u = new LocalUser()
      u.username = p[0]
      u.password = p[1]
      u.realName = p[2]
      u.phone = p[3]
      out.push(u)
    }
    return out
  }

  private static async persist(users: LocalUser[]): Promise<void> {
    const lines: string[] = []
    for (const u of users) {
      lines.push([
        XingyuCodec.clean(u.username),
        XingyuCodec.clean(u.password),
        XingyuCodec.clean(u.realName),
        XingyuCodec.clean(u.phone)
      ].join('\t'))
    }
    await LocalAuthStore.putString('users', lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (LocalAuthStore.pref === null) {
      return fallback
    }
    try {
      const v = await LocalAuthStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (LocalAuthStore.pref === null) {
      return
    }
    try {
      await LocalAuthStore.pref.put(key, value)
      await LocalAuthStore.pref.flush()
    } catch {
    }
  }
}
