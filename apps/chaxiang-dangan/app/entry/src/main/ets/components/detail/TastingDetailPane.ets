import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { TastingRecord } from '../../models/TeaModels'
import { TeaMedia } from '../../services/TeaMedia'
import { TeaNav } from '../../services/TeaNav'
import { TeaStore } from '../../services/TeaStore'

@Component
export struct TastingDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  /** 直接读路由，避免 BuilderParam 传入空 id */
  @StorageLink('tastingDetailId') @Watch('onTastingIdChange') tastingDetailId: string = ''
  @State rec: TastingRecord = new TastingRecord()
  @State teaArchiveId: string = ''
  @State teaName: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTastingIdChange(): void {
    this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private reload(): void {
    if (this.tastingDetailId.length === 0) {
      return
    }
    const found = TeaStore.findTasting(this.tastingDetailId)
    if (found === null) {
      this.teaName = ''
      this.teaArchiveId = ''
      return
    }
    this.rec = found
    this.teaArchiveId = found.teaId
    const tea = TeaStore.findTea(found.teaId)
    if (tea !== null) {
      this.teaName = tea.name
    } else if (found.teaId.length > 0) {
      this.teaName = '未知茶品'
    } else {
      this.teaName = '未关联茶品'
    }
  }

  private openTeaArchive(): void {
    let id = this.teaArchiveId
    if (id.length === 0) {
      id = this.rec.teaId
    }
    if (id.length === 0) {
      this.showToast('这条品饮未关联茶档案，请先编辑并选择茶品')
      return
    }
    const tea = TeaStore.findTea(id)
    if (tea === null) {
      this.showToast('关联的茶档案已不存在')
      return
    }
    TeaNav.openTea(id)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(TeaMedia.tasting())
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(80)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(28,46,38,0)', 0], ['rgba(28,46,38,0.8)', 1]]
                })
              Column({ space: 4 }) {
                Text(this.teaName.length > 0 ? this.teaName : '品饮详情')
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textOnInverse)
                Text(`${this.rec.dateKey.length > 0 ? this.rec.dateKey : '日期未填'} · ${this.rec.period}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textOnInverse)
              }
              .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
            }
            .clip(true)
            .borderRadius(Theme.radius.lg)

            AppCard({ title: '这次品饮' }) {
              Column({ space: 8 }) {
                Text(`心境 ${this.rec.mood}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
                if (this.rec.aromaFeel.length > 0) {
                  Text(`香气 ${this.rec.aromaFeel}`).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary)
                }
                if (this.rec.tasteFeel.length > 0) {
                  Text(`口感 ${this.rec.tasteFeel}`).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary)
                }
                Text(`评分 香气${this.rec.scoreAroma} 口感${this.rec.scoreTaste} 喜爱${this.rec.scoreLove} 收藏${this.rec.scoreKeep}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
                if (this.rec.note.length > 0) {
                  Text(this.rec.note).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary).lineHeight(22)
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }

            Row() {
              AppButton({
                label: '查看茶档案',
                variant: 'secondary',
                onTap: (): void => { this.openTeaArchive() }
              })
            }
            .width('100%')
            .onClick((): void => { this.openTeaArchive() })

            AppButton({
              label: '编辑这条记录',
              variant: 'primary',
              onTap: (): void => {
                TeaNav.openTastingEditor(this.teaArchiveId, this.rec.id)
              }
            })
            if (!this.confirmDelete) {
              AppButton({
                label: '删除记录',
                variant: 'ghost',
                onTap: (): void => { this.confirmDelete = true }
              })
            } else {
              AppButton({
                label: '确认删除这条品饮',
                variant: 'danger',
                onTap: (): void => {
                  void TeaStore.deleteTasting(this.rec.id).then((): void => {
                    this.onChanged()
                    TeaNav.closeTasting()
                  })
                }
              })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
