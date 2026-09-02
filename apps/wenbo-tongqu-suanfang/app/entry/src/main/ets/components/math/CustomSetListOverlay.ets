import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { CustomSet } from '../../models/MathModels'
import { MathBizService } from '../../services/MathBizService'
import { MathLocalStore } from '../../services/MathLocalStore'

@Component
export struct CustomSetListOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mathHomeTick') @Watch('onTick') dataTick: number = 0
  @State sets: CustomSet[] = []
  @State pendingId: string = ''
  onClose: () => void = () => {}
  onCreate: () => void = () => {}
  onEdit: (set: CustomSet) => void = (_s: CustomSet) => {}
  onPractice: (set: CustomSet) => void = (_s: CustomSet) => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.sets = MathLocalStore.snapshot().customSets
  }

  private askRemove(id: string): void {
    this.pendingId = id
  }

  private async remove(id: string): Promise<void> {
    await MathBizService.removeCustomSet(id)
    this.pendingId = ''
    this.reload()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('家长出题')
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Text('写下加减乘除算式，孩子按你的题单练。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.s6, right: Theme.space.s6, bottom: Theme.space.s3 })

      if (this.sets.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有题单',
            description: '从第一道家长出题开始',
            actionLabel: '写出第一份',
            onAction: () => this.onCreate()
          })
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center).width('100%')
      } else {
        List() {
          ForEach(this.sets, (set: CustomSet) => {
            ListItem() {
              Column({ space: Theme.space.s2 }) {
                Text(set.title)
                  .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`${set.items.length} 题 · ${set.createdAt}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Row({ space: Theme.space.s3 }) {
                  Text('去练习')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .onClick(() => this.onPractice(set))
                  Text('改题')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .onClick(() => this.onEdit(set))
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .onClick(() => this.askRemove(set.id))
                }
                .width('100%')
              }
              .width('100%').padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .margin({ bottom: Theme.space.s3 })
            }
          }, (set: CustomSet) => set.id)
        }
        .layoutWeight(1).padding({ left: Theme.space.s5, right: Theme.space.s5 })
        .scrollBar(BarState.Off)
      }

      if (this.pendingId.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这份题单？')
            .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('题目会从本机去掉，此操作不能恢复。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '确认删除',
            variant: 'danger',
            onTap: (): void => { void this.remove(this.pendingId) }
          })
          AppButton({ label: '取消', variant: 'secondary', onTap: () => { this.pendingId = '' } })
        }
        .padding(Theme.space.s5)
        .margin({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }

      Column() {
        AppButton({ label: '新建题单', onTap: () => this.onCreate() })
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6, bottom: Theme.space.s7 })
      .width('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
