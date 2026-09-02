import { DutySlot, FamilyMember } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'

export class MemberService {
  static list(): FamilyMember[] {
    return JujiaLocalStore.members()
  }

  static names(): string[] {
    const out: string[] = []
    for (const m of MemberService.list()) {
      out.push(m.name)
    }
    return out
  }

  static async add(name: string, role: string): Promise<FamilyMember> {
    const rows = MemberService.list().slice()
    const m = new FamilyMember()
    m.id = JujiaLocalStore.newId('mem')
    m.name = name.trim()
    m.role = role.length > 0 ? role : '家人'
    rows.push(m)
    await JujiaLocalStore.saveMembers(rows)
    await MemberService.rebuildDuties()
    return m
  }

  static async remove(id: string): Promise<void> {
    const next: FamilyMember[] = []
    for (const m of MemberService.list()) {
      if (m.id !== id) {
        next.push(m)
      }
    }
    await JujiaLocalStore.saveMembers(next)
    await MemberService.rebuildDuties()
  }

  static weekdayIndex(): number {
    const d = new Date().getDay()
    return d === 0 ? 7 : d
  }

  static weekdayLabel(n: number): string {
    const names = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日']
    if (n >= 1 && n <= 7) {
      return names[n]
    }
    return ''
  }

  static async rebuildDuties(): Promise<void> {
    const members = MemberService.list()
    const chores = ['倒垃圾', '洗碗', '浇花']
    const slots: DutySlot[] = []
    if (members.length === 0) {
      await JujiaLocalStore.saveDuties(slots)
      return
    }
    for (let day = 1; day <= 7; day++) {
      for (let c = 0; c < chores.length; c++) {
        const slot = new DutySlot()
        slot.weekday = day
        slot.chore = chores[c]
        const m = members[(day + c) % members.length]
        slot.memberId = m.id
        slot.memberName = m.name
        slots.push(slot)
      }
    }
    await JujiaLocalStore.saveDuties(slots)
  }

  static todaySlots(): DutySlot[] {
    const day = MemberService.weekdayIndex()
    const out: DutySlot[] = []
    for (const slot of JujiaLocalStore.duties()) {
      if (slot.weekday === day) {
        out.push(slot)
      }
    }
    return out
  }
}
