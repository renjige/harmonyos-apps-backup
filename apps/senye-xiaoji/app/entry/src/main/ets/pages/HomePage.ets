import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { NoteListCard } from '../components/note/NoteListCard'
import { NoteItem } from '../models/NoteModels'
import { NoteDateUtil } from '../services/NoteDateUtil'
import { NoteNav } from '../services/NoteNav'
import { NoteStore } from '../services/NoteStore'
import { SenyeMedia } from '../services/SenyeMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '森野小记'
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State notes: NoteItem[] = []
  @State streak: number = 0
  onOpenWrite: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.notes = NoteStore.sorted()
    this.streak = NoteStore.streakDays()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Column({ space: 2 }) {
            Text(this.appName)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('智慧记录，森野随行')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          if (this.streak > 0) {
            Row({ space: 4 }) {
              Text('🔥')
                .fontSize(14)
              Text(`连续 ${this.streak} 天`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(SenyeMedia.hero())
                .width('100%')
                .height(132)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(68)
                .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.78)', 1]]
                })
              Column({ space: 4 }) {
                Text(NoteDateUtil.homeDate(new Date()))
                  .fontSize(Theme.type.caption)
                  .fontColor('#F7F5F0')
                Text('记录此刻，让思绪在森野里生长')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F7F5F0')
              }
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4, right: Theme.space.s4 })
            }
            .width('100%')

            if (this.notes.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image(SenyeMedia.empty())
                  .width('100%')
                  .height(120)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.lg)
                AppEmpty({
                  title: '还没有记录',
                  description: '点击下方按钮，写下第一条森野小记',
                  actionLabel: '写记录',
                  onAction: (): void => { this.onOpenWrite() }
                })
              }
              .width('100%')
            } else {
              ForEach(this.notes, (item: NoteItem) => {
                NoteListCard({
                  item: item,
                  onTap: (): void => { NoteNav.openDetail(item.id) }
                })
              }, (item: NoteItem) => item.id)
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

      Column() {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.onOpenWrite() })
      }
      .padding({ right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
