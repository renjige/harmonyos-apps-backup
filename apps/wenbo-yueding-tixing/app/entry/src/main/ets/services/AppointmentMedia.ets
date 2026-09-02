import { AppointmentItem } from '../models/AppointmentModels'

/** 约定模板封面 — 每个 coverKey 独立 media 资源 */
export class AppointmentMedia {
  static cover(key: string): Resource {
    if (key === 'tpl_meeting') {
      return $r('app.media.tpl_meeting')
    }
    if (key === 'tpl_birthday') {
      return $r('app.media.tpl_birthday')
    }
    if (key === 'tpl_study') {
      return $r('app.media.tpl_study')
    }
    if (key === 'tpl_fitness') {
      return $r('app.media.tpl_fitness')
    }
    if (key === 'tpl_meal') {
      return $r('app.media.tpl_meal')
    }
    if (key === 'tpl_pickup') {
      return $r('app.media.tpl_pickup')
    }
    if (key === 'tpl_read') {
      return $r('app.media.tpl_read')
    }
    if (key === 'tpl_bill') {
      return $r('app.media.tpl_bill')
    }
    if (key === 'banner_schedule') {
      return $r('app.media.banner_schedule')
    }
    return $r('app.media.hero_appointment')
  }

  static coverForItem(item: AppointmentItem): Resource {
    if (item.templateId.length > 0) {
      return AppointmentMedia.cover(item.templateId)
    }
    if (item.scene === 'work') {
      return $r('app.media.tpl_meeting')
    }
    if (item.scene === 'study') {
      return $r('app.media.tpl_study')
    }
    if (item.scene === 'health') {
      return $r('app.media.tpl_fitness')
    }
    return $r('app.media.tpl_birthday')
  }
}
