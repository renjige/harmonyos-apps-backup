import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { NoteItem } from '../../models/SlipModels'
import { SlipStore } from '../../services/SlipStore'
import { SlipNav } from '../../services/SlipNav'
import { SlipDateUtil } from '../../services/SlipDateUtil'
import { SlipMedia } from '../../services/SlipMedia'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct InspirationCardPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @State item: NoteItem = new NoteItem()
  @State templateKey: string = 'plain'
  @State toastText: string = ''

  aboutToAppear(): void {
    const found = SlipStore.find(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.templateKey = found.cardTemplate.length > 0 ? found.cardTemplate : 'plain'
    }
  }

  private isDarkTpl(): boolean {
    return this.templateKey === 'ink' || this.templateKey === 'night'
  }

  private titleColor(): string {
    return this.isDarkTpl() ? '#F7F3EA' : '#18233A'
  }

  private bodyColor(): string {
    return this.isDarkTpl() ? '#E8E2D4' : '#293044'
  }

  private metaColor(): string {
    return this.isDarkTpl() ? '#D9AE62' : '#858B99'
  }

  private async applyTemplate(key: string): Promise<void> {
    this.templateKey = key
    this.item.cardTemplate = key
    this.item.updatedAt = Date.now()
    await SlipStore.save(this.item)
  }

  private cardText(): string {
    const tags = this.item.tagList()
    let tagLine = ''
    for (const t of tags) {
      tagLine = tagLine.length === 0 ? `#${t}` : `${tagLine} #${t}`
    }
    return `灵感拾光\n\n${this.item.body}\n\n${tagLine}\n${SlipDateUtil.cardDate(this.item.noteDate)}\n灵感笺`
  }

  private async saveOut(): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.cardText())
      await pasteboard.getSystemPasteboard().setData(data)
      this.toastText = '已复制卡片文字。可用系统截图把画面保存到相册，不额外申请权限。'
    } catch {
      this.toastText = '请长按卡片画面，使用系统截图保存到相册。'
    }
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { SlipNav.closeCard() })
          Text('灵感卡')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.Center }) {
              Image(SlipMedia.cover(SlipMedia.forTemplate(this.templateKey)))
                .width('100%')
                .height(420)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(420)
                .borderRadius(Theme.radius.xl)
                .backgroundColor(this.isDarkTpl() ? 'rgba(24,35,58,0.55)' : 'rgba(247,243,234,0.62)')
              Column({ space: 16 }) {
                Text('灵感拾光')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.metaColor())
                  .letterSpacing(2)
                Text(this.item.body.length > 0 ? this.item.body : this.item.displayTitle())
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.titleColor())
                  .lineHeight(28)
                  .width('100%')
                  .textAlign(TextAlign.Start)
                Row({ space: 8 }) {
                  ForEach(this.item.tagList(), (tag: string) => {
                    Text(`#${tag}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.metaColor())
                  }, (tag: string) => tag)
                }
                .width('100%')
                Text(SlipDateUtil.cardDate(this.item.noteDate))
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.bodyColor())
                  .width('100%')
                Text('灵感笺')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.metaColor())
                  .width('100%')
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .padding(28)
            }
            .width('100%')

            Text('笺面')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              ForEach(MoodCatalog.templateNames(), (key: string) => {
                Text(MoodCatalog.templateLabel(key))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.templateKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.templateKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.applyTemplate(key) })
              }, (key: string) => key)
            }
            .width('100%')

            AppButton({ label: '保存图片', onTap: (): void => { void this.saveOut() } })
            Text('本版不申请相册权限。点保存会复制卡片文字；画面请用系统截图收入相册。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
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
            .maxLines(4)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
