import { CalendarPage } from './CalendarPage'

@Component
export struct DashboardPage {
  onRequireAuth?: () => void

  build() {
    CalendarPage({
      onRequireAuth: this.onRequireAuth
    })
  }
}
