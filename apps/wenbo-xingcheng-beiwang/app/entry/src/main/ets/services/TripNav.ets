export class TripNav {
  static openCreate(): void {
    AppStorage.setOrCreate('tripFormId', '')
    AppStorage.setOrCreate('showTripForm', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openEditTrip(id: string): void {
    AppStorage.setOrCreate('tripFormId', id)
    AppStorage.setOrCreate('showTripForm', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeForm(): void {
    AppStorage.setOrCreate('showTripForm', false)
    AppStorage.setOrCreate('tripFormId', '')
    TripNav.restoreBar()
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('detailTripId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailTripId', '')
    TripNav.restoreBar()
  }

  static openItemForm(tripId: string, itemId: string): void {
    AppStorage.setOrCreate('itemFormTripId', tripId)
    AppStorage.setOrCreate('itemFormId', itemId)
    AppStorage.setOrCreate('showItemForm', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeItemForm(): void {
    AppStorage.setOrCreate('showItemForm', false)
    AppStorage.setOrCreate('itemFormId', '')
    const detail = AppStorage.get<string>('detailTripId') ?? ''
    if (detail.length === 0) {
      TripNav.restoreBar()
    }
  }

  static openTemplates(): void {
    AppStorage.setOrCreate('showTemplates', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTemplates(): void {
    AppStorage.setOrCreate('showTemplates', false)
    TripNav.restoreBar()
  }

  static openCalendar(): void {
    AppStorage.setOrCreate('showCalendar', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCalendar(): void {
    AppStorage.setOrCreate('showCalendar', false)
    TripNav.restoreBar()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('showSearch', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('showSearch', false)
    TripNav.restoreBar()
  }

  static setHomeDate(iso: string): void {
    AppStorage.setOrCreate('homeDateIso', iso)
  }

  static restoreBar(): void {
    const form = AppStorage.get<boolean>('showTripForm') === true
    const item = AppStorage.get<boolean>('showItemForm') === true
    const detail = (AppStorage.get<string>('detailTripId') ?? '').length > 0
    const tpl = AppStorage.get<boolean>('showTemplates') === true
    const cal = AppStorage.get<boolean>('showCalendar') === true
    const search = AppStorage.get<boolean>('showSearch') === true
    const mine = AppStorage.get<boolean>('minePanelOpen') === true
    AppStorage.setOrCreate('tabBarHidden', form || item || detail || tpl || cal || search || mine)
  }
}
