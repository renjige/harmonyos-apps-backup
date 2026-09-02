import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { HomePage } from './HomePage'
import { SummaryPage } from './SummaryPage'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { ExpressScenarioStrip } from '../components/polish/ExpressScenarioStrip'
import { ExpressWorkflowStrip } from '../components/polish/ExpressWorkflowStrip'
import { ExpressCapabilityBanner } from '../components/polish/ExpressCapabilityBanner'

@Component
export struct ExpressPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('expressSegment') @Watch('onSegment') segment: number = 0
  @StorageLink('expressToast') expressToast: string = ''
  @StorageLink('expressToastTick') expressToastTick: number = 0
  @Prop appName: string = '研语'
  @State current: number = 0

  aboutToAppear(): void {
    this.current = this.segment
  }

  onSegment(): void {
    this.current = this.segment
  }

  build() {
    Column() {
      AppHeader({ title: '表达', subtitle: '场景 · 成稿 · 工作流 · 润色 · 摘要 · 诊断' })

      if (this.expressToast.length > 0) {
        Column() {
          Text(this.expressToast)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }

      Scroll() {
        Column() {
          ExpressCapabilityBanner()

          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '使用指南',
                onTap: (): void => { LanguageCraftNav.openUseCaseGuide() }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '场景库',
                variant: 'secondary',
                onTap: (): void => { LanguageCraftNav.openScenarioLibrary() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

          ExpressWorkflowStrip()

          ExpressScenarioStrip()

          Row({ space: Theme.space.s2 }) {
            this.segTab('润色', 0)
            this.segTab('摘要', 1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '场景成稿',
                variant: 'secondary',
                onTap: (): void => { LanguageCraftNav.openDraft('') }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '表达诊断',
                variant: 'secondary',
                onTap: (): void => { LanguageCraftNav.openDiagnose() }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '范例收藏',
                variant: 'secondary',
                onTap: (): void => { LanguageCraftNav.openFavorites() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

          if (this.current === 0) {
            HomePage({ appName: this.appName, embedded: true })
          } else {
            SummaryPage({ embedded: true })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }

  @Builder
  segTab(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontWeight(this.current === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === index ?
          Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(this.current === index ?
      Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
    .borderRadius(Theme.radius.pill)
    .onClick((): void => {
      this.current = index
      AppStorage.setOrCreate('expressSegment', index)
    })
  }
}
