import { ArchivePage } from './ArchivePage'

@Component
export struct DataInsightsPage {
  @Prop reloadToken: number = 0
  onClose: () => void = () => {}

  build() {
    ArchivePage({
      reloadToken: this.reloadToken,
      modalMode: true,
      onClose: (): void => { this.onClose() }
    })
  }
}
