import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ExperimentNote } from '../models/KitchenLabModels'
import { KitchenLabBizService } from '../services/KitchenLabBizService'
import { KitchenLabDetailNav } from '../services/KitchenLabDetailNav'

@Component
export struct NotesListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kitchenTick') kitchenTick: number = 0
  @State notes: ExperimentNote[] = []
  @State loading: boolean = true
  onClose: () => void = () => {}
  onToast: (message: string) => void = (_m: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.notes = await KitchenLabBizService.loadNotes()
    this.loading = false
  }

  private async deleteNote(id: string): Promise<void> {
    const ok = await KitchenLabBizService.deleteNote(id)
    if (ok) {
      await this.reload()
      this.onToast('已删除笔记')
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            .rotate({ angle: 180 })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('实验笔记')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
      } else if (this.notes.length === 0) {
        AppEmpty({
          title: '暂无实验笔记',
          description: '在菜谱详情页可记录每次烹饪实验心得'
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.notes, (n: ExperimentNote) => {
              Column({ space: Theme.space.s2 }) {
                Text(n.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                if (n.summary.length > 0) {
                  Text(n.summary)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                if (n.modifications.length > 0) {
                  Text(`调整：${n.modifications}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                }
                Row({ space: Theme.space.s3 }) {
                  if (n.recipeId.length > 0) {
                    AppButton({
                      label: '查看菜谱',
                      variant: 'secondary',
                      onTap: (): void => KitchenLabDetailNav.open('recipe', n.recipeId)
                    })
                    .layoutWeight(1)
                  }
                  AppButton({
                    label: '删除',
                    variant: 'ghost',
                    onTap: (): void => { void this.deleteNote(n.id) }
                  })
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (n: ExperimentNote) => n.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
