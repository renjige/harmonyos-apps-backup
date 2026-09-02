import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CollectionItem } from '../models/AskModels'
import { AskMedia } from '../services/AskMedia'
import { AskNav } from '../services/AskNav'
import { VaultStore } from '../services/VaultStore'
import { VaultPlatformSection } from '../components/vault/VaultPlatformSection'

@Component
export struct VaultPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State folder: string = '全部'
  @State tag: string = '全部'
  @State keyword: string = ''
  @State items: CollectionItem[] = []
  @State toastText: string = ''
  private folders: string[] = ['全部', '生活百科', '科普知识', '历史文化', '学习知识', '健康常识', '趣味知识']
  private tags: string[] = ['全部', '已学习', '待了解', '重点收藏']

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = this.filtered()
  }

  private filtered(): CollectionItem[] {
    const all = VaultStore.all()
    const out: CollectionItem[] = []
    const k = this.keyword.trim()
    for (const n of all) {
      if (this.folder !== '全部' && n.folder !== this.folder) {
        continue
      }
      if (this.tag !== '全部' && n.userTag !== this.tag) {
        continue
      }
      if (k.length > 0) {
        const hay = `${n.question} ${n.summary} ${n.note} ${n.tags}`
        if (!hay.includes(k)) {
          continue
        }
      }
      out.push(n)
    }
    return out
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('知识库')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('专题库')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { AskNav.openLearn('topics') })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s2
        })

        TextInput({ text: this.keyword, placeholder: '搜索收藏的问题、备注或标签' })
          .height(48)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
          .fontSize(Theme.type.body)
          .placeholderColor(Theme.colors().textTertiary)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => {
            this.keyword = v
            this.reload()
          })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            VaultPlatformSection({ refreshToken: this.refreshToken })

            Text('我的收藏')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.folders, (f: string) => {
                  Text(f)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.folder === f ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .constraintSize({ minHeight: 40 })
                    .backgroundColor(this.folder === f ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => {
                      this.folder = f
                      this.reload()
                    })
                }, (f: string) => f)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.tags, (f: string) => {
                  Text(f)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.tag === f ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .constraintSize({ minHeight: 40 })
                    .backgroundColor(this.tag === f ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => {
                      this.tag = f
                      this.reload()
                    })
                }, (f: string) => `tag_${f}`)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有个人收藏',
                description: '浏览上方百科条目，点进详情后可收藏并写笔记',
                actionLabel: '浏览百科',
                onAction: (): void => { AskNav.openLearn('catalog') }
              })
            } else {
              ForEach(this.items, (n: CollectionItem) => {
                Row({ space: Theme.space.s3 }) {
                  Image(AskMedia.resource(n.coverKey))
                    .width(72)
                    .height(72)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.sm)
                  Column({ space: 4 }) {
                    Text(n.question)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                    Text(`${n.folder} · ${n.userTag} · ${VaultStore.formatDate(n.createdAt)}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    if (n.note.length > 0) {
                      Text(n.note)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textTertiary)
                        .maxLines(1)
                        .width('100%')
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.card)
                .onClick(() => { AskNav.openDetail('collection', n.id) })
              }, (n: CollectionItem) => n.id)
            }
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
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
