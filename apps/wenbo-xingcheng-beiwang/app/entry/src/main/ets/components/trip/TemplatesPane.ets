import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { TplItem } from '../../models/TripModels'
import { TripBizService } from '../../services/TripBizService'
import { TripMedia } from '../../services/TripMedia'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'

@Component
export struct TemplatesPane {
  @State list: TplItem[] = []
  @State loading: boolean = true
  @State errorText: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.errorText = ''
    this.list = await TripBizService.loadTemplates()
    this.loading = false
    if (this.list.length === 0) {
      this.errorText = '暂时无法加载模板，请稍后再试。'
    }
  }

  private async useTpl(tpl: TplItem): Promise<void> {
    const id = await TripStore.applyTemplate(tpl)
    AppStorage.setOrCreate('toastText', `已用「${tpl.title}」生成行程`)
    TripNav.closeTemplates()
    TripNav.openDetail(id)
  }

  build() {
    Column() {
      AppNavBar({
        title: '行程模板',
        onBack: (): void => { TripNav.closeTemplates() }
      })
      Text('三个简单结构，生成后可再改。')
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.palette(this.darkModeOn).textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.palette(this.darkModeOn).danger)
          .padding({ left: Theme.space.pageX })
      }
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          ForEach(this.list, (tpl: TplItem) => {
            Column({ space: 10 }) {
              Image(TripMedia.cover(tpl.coverKey))
                .width('100%')
                .height(132)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              Text(tpl.title)
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.palette(this.darkModeOn).textPrimary)
                .width('100%')
              Text(tpl.summary)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.palette(this.darkModeOn).textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { void this.useTpl(tpl) })
          }, (tpl: TplItem) => tpl.id)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}
