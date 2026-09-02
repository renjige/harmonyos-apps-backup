import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LocalPhotoImage } from '../components/album/LocalPhotoImage'
import { Anniversary, FamilyMember, FamilyPhoto, MemoryCard, RecapSummary } from '../models/AlbumModels'
import { AlbumStore } from '../services/AlbumStore'
import { AlbumNav } from '../services/AlbumNav'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('albumRev') @Watch('onAlbumRev') storeRev: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}

  @State familyName: string = ''
  @State members: FamilyMember[] = []
  @State groups: MemoryCard[] = []
  @State memoryPhotos: FamilyPhoto[] = []
  @State memoryPreview: FamilyPhoto[] = []
  @State recap: RecapSummary = new RecapSummary()
  @State days: Anniversary[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  onAlbumRev(): void {
    this.reload()
  }

  private reload(): void {
    this.familyName = AlbumStore.profile().name
    this.members = AlbumStore.members()
    this.groups = AlbumStore.timelineGroups()
    this.memoryPhotos = AlbumStore.memoryToday()
    const preview: FamilyPhoto[] = []
    let n = 0
    for (const p of this.memoryPhotos) {
      if (n >= 3) {
        break
      }
      preview.push(p)
      n += 1
    }
    this.memoryPreview = preview
    this.recap = AlbumStore.recap()
    this.days = AlbumStore.upcomingAnniversaries()
  }

  private dateLabel(card: MemoryCard): string {
    return `${card.year}年${card.month}月${card.day}日`
  }

  @Builder
  MemberAvatar(m: FamilyMember) {
    Column() {
      Column() {
        Text(m.name.length > 0 ? m.name.substring(0, 1) : '?')
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor(m.avatarColor)
      .justifyContent(FlexAlign.Center)
      Text(m.relation)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .margin({ top: 4 })
    }
    .margin({ right: Theme.space.s3 })
    .onClick((): void => { AlbumNav.openFilter('people', m.id) })
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_bg'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(120)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(45,58,74,0.72)', 1]]
              })
            Column() {
              Text(this.familyName)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('一家人的记忆，一本就够了')
                .fontSize(Theme.type.caption)
                .fontColor('#F5F0E8')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: Theme.space.pageX, bottom: Theme.space.s4 })
          }
          .width('100%')
          .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
          .clip(true)

          Scroll() {
            Row() {
              ForEach(this.members, (m: FamilyMember) => {
                this.MemberAvatar(m)
              }, (m: FamilyMember) => m.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column() {
              Text(`${this.recap.photoCount}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('照片')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            Column() {
              Text(`${this.recap.thisMonth}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('本月')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            Column() {
              Text('年册')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandOnPrimary : Theme.colors().brandOnPrimary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.card)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { AlbumNav.openRecap() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

          if (this.days.length > 0) {
            Text(`本月纪念日 · ${this.days[0].title} ${this.days[0].month}月${this.days[0].day}日`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
              .width('100%')
          }

          if (this.memoryPhotos.length > 0) {
            Column() {
              Text('智慧回忆 · 往年的今天')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Row() {
                ForEach(this.memoryPreview, (p: FamilyPhoto) => {
                  LocalPhotoImage({ uri: p.uri, tileW: 96, tileH: 96, radius: Theme.radius.md })
                    .margin({ right: Theme.space.s2 })
                    .onClick((): void => { AlbumNav.openDetail(p.id) })
                }, (p: FamilyPhoto) => p.id)
              }
              .margin({ top: Theme.space.s3 })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
          }

          Row() {
            Text('时光轴')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Row() {
              AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
              Text('上传')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .margin({ left: 4 })
            }
            .height(48)
            .padding({ left: 12, right: 12 })
            .onClick((): void => { AlbumNav.openUpload() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6, bottom: Theme.space.s3 })

          if (this.groups.length === 0) {
            AppEmpty({
              title: '还没有家庭照片',
              description: '上传后会按日期排进时光轴，并按人物/地点自动分册',
              actionLabel: '上传照片',
              onAction: (): void => { AlbumNav.openUpload() }
            })
              .margin({ top: Theme.space.s4 })
          } else {
            ForEach(this.groups, (g: MemoryCard) => {
              Column() {
                Text(this.dateLabel(g))
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .margin({ bottom: Theme.space.s2 })
                ForEach(g.photos, (p: FamilyPhoto) => {
                  Row() {
                    LocalPhotoImage({ uri: p.uri, tileW: 72, tileH: 72, radius: Theme.radius.md })
                    Column() {
                      Text(p.caption.length > 0 ? p.caption : '家庭瞬间')
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(`${p.location} · ${p.uploadedBy}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    .margin({ left: Theme.space.s3 })
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.card)
                  .margin({ bottom: Theme.space.s2 })
                  .onClick((): void => { AlbumNav.openDetail(p.id) })
                }, (p: FamilyPhoto) => `${p.id}-${p.uri}`)
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
            }, (g: MemoryCard) => `${g.year}-${g.month}-${g.day}-${g.photos.length}`)
          }
        }
        .padding({ bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
