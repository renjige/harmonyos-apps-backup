/** 全局详情 / 表单 Overlay 路由 */
export class CourtDetailNav {
  static openVenue(venueId: string): void {
    AppStorage.setOrCreate('courtVenueId', venueId)
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('courtSlotTime', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openPromotion(promotionId: string): void {
    AppStorage.setOrCreate('courtPromotionId', promotionId)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openCase(caseId: string): void {
    AppStorage.setOrCreate('courtCaseId', caseId)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openBooking(venueId: string, slotTime: string): void {
    AppStorage.setOrCreate('courtBookingVenueId', venueId)
    AppStorage.setOrCreate('courtSlotTime', slotTime)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('showCourtDiagnose', true)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openBookings(): void {
    AppStorage.setOrCreate('showCourtBookings', true)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('showCourtFavorites', true)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showCourtMessages', true)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtFanList', false)
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFanList(kind: string): void {
    AppStorage.setOrCreate('courtFanKind', kind)
    AppStorage.setOrCreate('showCourtFanList', true)
    AppStorage.setOrCreate('courtFanId', '')
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('courtFanEditId', '')
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('showCourtFanCalendar', false)
    AppStorage.setOrCreate('showCourtFanTimeline', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFanTimeline(): void {
    AppStorage.setOrCreate('showCourtFanTimeline', true)
    AppStorage.setOrCreate('showCourtFanList', false)
    AppStorage.setOrCreate('showCourtFanCalendar', false)
    AppStorage.setOrCreate('showCourtFanWizard', false)
    AppStorage.setOrCreate('showCourtFanDashboard', false)
    AppStorage.setOrCreate('courtFanId', '')
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFanTimeline(): void {
    AppStorage.setOrCreate('showCourtFanTimeline', false)
    const editorOn = AppStorage.get<boolean>('showCourtFanEditor') ?? false
    const listOn = AppStorage.get<boolean>('showCourtFanList') ?? false
    const wizardOn = AppStorage.get<boolean>('showCourtFanWizard') ?? false
    const dashOn = AppStorage.get<boolean>('showCourtFanDashboard') ?? false
    const fanId = AppStorage.get<string>('courtFanId') ?? ''
    if (!editorOn && !listOn && !wizardOn && !dashOn && fanId.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openFanWizard(): void {
    AppStorage.setOrCreate('showCourtFanWizard', true)
    AppStorage.setOrCreate('showCourtFanDashboard', false)
    AppStorage.setOrCreate('showCourtFanTimeline', false)
    AppStorage.setOrCreate('showCourtFanList', false)
    AppStorage.setOrCreate('showCourtFanCalendar', false)
    AppStorage.setOrCreate('courtFanId', '')
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFanWizard(): void {
    AppStorage.setOrCreate('showCourtFanWizard', false)
    const dashOn = AppStorage.get<boolean>('showCourtFanDashboard') ?? false
    const timelineOn = AppStorage.get<boolean>('showCourtFanTimeline') ?? false
    const editorOn = AppStorage.get<boolean>('showCourtFanEditor') ?? false
    const listOn = AppStorage.get<boolean>('showCourtFanList') ?? false
    const fanId = AppStorage.get<string>('courtFanId') ?? ''
    if (!dashOn && !timelineOn && !editorOn && !listOn && fanId.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openFanDashboard(): void {
    AppStorage.setOrCreate('showCourtFanDashboard', true)
    AppStorage.setOrCreate('showCourtFanWizard', false)
    AppStorage.setOrCreate('showCourtFanTimeline', false)
    AppStorage.setOrCreate('showCourtFanList', false)
    AppStorage.setOrCreate('showCourtFanCalendar', false)
    AppStorage.setOrCreate('courtFanId', '')
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFanDashboard(): void {
    AppStorage.setOrCreate('showCourtFanDashboard', false)
    const wizardOn = AppStorage.get<boolean>('showCourtFanWizard') ?? false
    const timelineOn = AppStorage.get<boolean>('showCourtFanTimeline') ?? false
    const editorOn = AppStorage.get<boolean>('showCourtFanEditor') ?? false
    const listOn = AppStorage.get<boolean>('showCourtFanList') ?? false
    const fanId = AppStorage.get<string>('courtFanId') ?? ''
    if (!wizardOn && !timelineOn && !editorOn && !listOn && fanId.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openFanDetail(id: string): void {
    AppStorage.setOrCreate('courtFanId', id)
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFanEditor(kind: string, id: string): void {
    AppStorage.setOrCreate('courtFanKind', kind)
    AppStorage.setOrCreate('courtFanEditId', id)
    AppStorage.setOrCreate('showCourtFanEditor', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFanEditor(): void {
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('courtFanEditId', '')
  }

  static closeFanDetail(): void {
    AppStorage.setOrCreate('courtFanId', '')
  }

  static openFanCalendar(): void {
    AppStorage.setOrCreate('showCourtFanCalendar', true)
    AppStorage.setOrCreate('showCourtFanList', false)
    AppStorage.setOrCreate('courtFanId', '')
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFanTimeline', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFanCalendar(): void {
    AppStorage.setOrCreate('showCourtFanCalendar', false)
    const editorOn = AppStorage.get<boolean>('showCourtFanEditor') ?? false
    const listOn = AppStorage.get<boolean>('showCourtFanList') ?? false
    const timelineOn = AppStorage.get<boolean>('showCourtFanTimeline') ?? false
    const fanId = AppStorage.get<string>('courtFanId') ?? ''
    if (!editorOn && !listOn && !timelineOn && fanId.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static closeFanList(): void {
    AppStorage.setOrCreate('showCourtFanList', false)
    AppStorage.setOrCreate('showCourtFanCalendar', false)
    AppStorage.setOrCreate('showCourtFanTimeline', false)
    AppStorage.setOrCreate('showCourtFanWizard', false)
    AppStorage.setOrCreate('showCourtFanDashboard', false)
    AppStorage.setOrCreate('courtFanKind', '')
    AppStorage.setOrCreate('courtFanId', '')
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('courtFanEditId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static close(): void {
    AppStorage.setOrCreate('courtVenueId', '')
    AppStorage.setOrCreate('courtPromotionId', '')
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtBookingVenueId', '')
    AppStorage.setOrCreate('courtSlotTime', '')
    AppStorage.setOrCreate('showCourtDiagnose', false)
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('showCourtFanList', false)
    AppStorage.setOrCreate('showCourtFanEditor', false)
    AppStorage.setOrCreate('showCourtFanCalendar', false)
    AppStorage.setOrCreate('showCourtFanTimeline', false)
    AppStorage.setOrCreate('showCourtFanWizard', false)
    AppStorage.setOrCreate('showCourtFanDashboard', false)
    AppStorage.setOrCreate('courtFanKind', '')
    AppStorage.setOrCreate('courtFanId', '')
    AppStorage.setOrCreate('courtFanEditId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }
}
