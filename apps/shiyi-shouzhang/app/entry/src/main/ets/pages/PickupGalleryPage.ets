import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { PickupCardView } from '../components/journal/PickupCardView'
import { ShiyiEmpty } from '../components/journal/ShiyiEmpty'
import { PickupItem, PickupKindOption } from '../models/ShiyiModels'
import { PickupKinds } from '../services/MoodCatalog'
import { ShiyiNav } from '../services/ShiyiNav'
import { ShiyiStore } from '../services/ShiyiStore'

@Component
export struct PickupGalleryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  @State items: PickupItem[] = []
  @State draft: string = ''
  @State kind: string = 'inspiration'
  @State showComposer: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ShiyiStore.pickups()
  }

  private async addPickup(): Promise<void> {
    if (this.draft.trim().length === 0) {
      this.onToast('先写下一句拾意。')
      return
    }
    const item = new PickupItem()
    item.id = ShiyiStore.newId('p')
    item.kind = this.kind
    item.text = this.draft.trim()
    item.createdAt = Date.now()
    const ok = await ShiyiStore.savePickup(item)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    this.draft = ''
    this.showComposer = false
    this.reload()
    this.onToast('已收进我的拾意')
  }

  private async remove(id: string): Promise<void> {
    const ok = await ShiyiStore.deletePickup(id)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    this.reload()
  }

  build() {
    Column() {
      AppNavBar({
        title: '我的拾意',
        onBack: (): void => {
          ShiyiNav.closePickup()
        }
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('灵感、句子与小确幸，安静地放在这里。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          AppButton({
            label: this.showComposer ? '收起' : '收进一句新的拾意',
            variant: 'secondary',
            onTap: (): void => {
              this.showComposer = !this.showComposer
            }
          })

          if (this.showComposer) {
            Column({ space: Theme.space.s3 }) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(PickupKinds.all(), (opt: PickupKindOption) => {
                  Text(opt.label)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.kind === opt.id ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.kind === opt.id ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.tag)
                    .onClick(() => {
                      this.kind = opt.id
                    })
                }, (opt: PickupKindOption) => opt.id)
              }
              .width('100%')
              TextArea({ text: this.draft, placeholder: '写下想留下的一句…' })
                .height(96)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.xl)
                .onChange((v: string) => {
                  this.draft = v
                })
              AppButton({
                label: '收进我的拾意',
                onTap: (): void => {
                  void this.addPickup()
                }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
          }

          if (this.items.length === 0) {
            ShiyiEmpty({
              title: '拾意画廊还是空的。',
              description: '收藏手账，或在这里写下第一句。'
            })
          } else {
            ForEach(this.items, (item: PickupItem) => {
              Column({ space: Theme.space.s2 }) {
                PickupCardView({ item: item })
                Text('从画廊里轻轻放下')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .onClick(() => {
                    void this.remove(item.id)
                  })
              }
              .width('100%')
              .margin({ bottom: Theme.space.s4 })
              .alignItems(HorizontalAlign.Start)
            }, (item: PickupItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
