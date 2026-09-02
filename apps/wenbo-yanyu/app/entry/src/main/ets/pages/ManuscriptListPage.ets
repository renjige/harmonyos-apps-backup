import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ResearchBar } from '../components/research/ResearchBar'
import { Manuscript } from '../models/HubModels'
import { HubStore } from '../services/HubStore'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { ClipboardService } from '../services/ClipboardService'

@Component
export struct ManuscriptListPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('hubRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: Manuscript[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.items = await HubStore.listManuscripts()
  }

  private async copyBody(body: string): Promise<void> {
    const ok = await ClipboardService.copyText(body)
    this.showToast(ok ? '已复制稿本' : '复制失败')
  }

  private async remove(id: string): Promise<void> {
    await HubStore.deleteManuscript(id)
    this.showToast('已删除稿本')
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '稿本库', onBack: (): void => { LanguageCraftNav.closeManuscripts() } })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('润色与摘要保存的成稿，可再次复制或送到润色台。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有稿本',
                description: '在润色或摘要结果处点「存为稿本」，成稿会集中保存在这里。',
                actionLabel: '去润色',
                onAction: (): void => {
                  LanguageCraftNav.closeManuscripts()
                  AppStorage.setOrCreate('mainTabIndex', 1)
                  AppStorage.setOrCreate('expressSegment', 0)
                }
              })
            } else {
              ForEach(this.items, (m: Manuscript) => {
                Column({ space: Theme.space.s2 }) {
                  Text(m.title.length > 0 ? m.title : '未命名稿本')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  Text(m.body)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .maxLines(4)
                    .width('100%')
                  Row({ space: Theme.space.s2 }) {
                    Column() {
                      AppButton({
                        label: '复制',
                        variant: 'secondary',
                        onTap: (): void => { void this.copyBody(m.body) }
                      })
                    }
                    .layoutWeight(1)
                    Column() {
                      AppButton({
                        label: '再润色',
                        variant: 'secondary',
                        onTap: (): void => {
                          LanguageCraftNav.closeManuscripts()
                          LanguageCraftNav.applyToPolish(m.body)
                        }
                      })
                    }
                    .layoutWeight(1)
                    Column() {
                      AppButton({
                        label: '删除',
                        variant: 'ghost',
                        onTap: (): void => { void this.remove(m.id) }
                      })
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              }, (m: Manuscript) => m.id)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
