import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { SportDraft, SportRecord } from '../../models/SportModels'
import { SportStore } from '../../services/SportStore'
import { SportAnalytics } from '../../services/SportAnalytics'
import { SportRecordService } from '../../services/SportRecordService'
import { SportDetailNav } from '../../services/SportDetailNav'
import { FavoriteStore } from '../../services/FavoriteStore'
import { TagService } from '../../services/TagService'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { SportModelClone } from '../../services/SportModelClone'

@Component
export struct SportRecordDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recordId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State record: SportRecord = new SportRecord()
  @State pbHint: string = ''
  @State confirmDelete: boolean = false
  @State showEdit: boolean = false
  @State draft: SportDraft = SportRecordService.emptyDraft()
  @State formError: string = ''
  @State isFavorite: boolean = false
  @State detailRev: number = 0
  @State sessionHint: string = ''
  @StorageLink('sportDataEpoch') @Watch('onSportDataEpochChange') sportDataEpoch: number = 0
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  onRefreshTokenChange(): void {
    this.load()
  }

  onSportDataEpochChange(): void {
    this.load()
  }

  private applyRecord(found: SportRecord): void {
    this.record = found
    this.pbHint = this.buildPbHint(found)
    this.isFavorite = FavoriteStore.isFavorite('record', found.id)
    this.sessionHint = SportAnalytics.sessionCompare(found).message
    this.detailRev += 1
  }

  private load(): void {
    const found = SportStore.findById(this.recordId)
    if (found !== null) {
      this.applyRecord(found)
    }
  }

  private buildPbHint(cur: SportRecord): string {
    const pb = SportAnalytics.personalBest(cur.sportType)
    if (pb === null || pb.distanceKm <= 0) {
      return '该项目尚无距离个人最佳，补上里程后可对照。'
    }
    if (pb.id === cur.id) {
      return `这是「${cur.sportType}」当前距离个人最佳。`
    }
    const delta = pb.distanceKm - cur.distanceKm
    if (delta <= 0) {
      return `已达到或超过个人最佳 ${pb.distanceKm.toFixed(1)} km。`
    }
    return `个人最佳 ${pb.distanceKm.toFixed(1)} km（${pb.recordDate}），本场还差 ${delta.toFixed(1)} km。`
  }

  build() {
    if (this.showEdit) {
      this.EditSheet()
    } else {
      DetailShell({
        title: '竞技详情',
        bodyKey: this.detailRev,
        onClose: (): void => {
          SportDetailNav.close()
        },
        body: (): void => {
          this.BodyContent()
        },
        footer: (): void => {
          this.FooterActions()
        }
      })
    }
  }

  @Builder
  BodyContent() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_sport_bg'))
        .width('100%')
        .height(240)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column({ space: 0 })
        .width('100%')
        .height(240)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrim()
        })
      Column({ space: 8 }) {
        Text(this.record.recordDate)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textOnScrimMuted)
        Text(this.record.sportType)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnScrim)
        Text(`${this.record.durationMin} 分钟 · ${this.record.distanceKm > 0 ? this.record.distanceKm.toFixed(1) + ' km' : '未填里程'}`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnScrimMuted)
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }

    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text('时长')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text(`${this.record.durationMin} 分`)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Column({ space: 4 }) {
        Text('距离')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text(this.record.distanceKm > 0 ? `${this.record.distanceKm.toFixed(1)} km` : '—')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
    .width('100%')

    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text('体感')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text(this.record.feeling.length > 0 ? this.record.feeling : '—')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Column({ space: 4 }) {
        Text('天气')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text(this.record.weather.length > 0 ? this.record.weather : '—')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
    .width('100%')

    if (TagService.parseTags(this.record.tags).length > 0) {
      Row({ space: Theme.space.s2 }) {
        ForEach(TagService.parseTags(this.record.tags), (tag: string) => {
          Text(`#${tag}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }, (tag: string) => tag)
      }
      .width('100%')
    }

    Column({ space: Theme.space.s3 }) {
      Text('竞技复盘')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.record.takeaway.length > 0 ? this.record.takeaway : '还没有写下本场收获，点编辑补上。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .lineHeight(24)
        .width('100%')
      Text(this.record.nextFocus.length > 0 ? `下次重点：${this.record.nextFocus}` : '下次重点未填')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
      if (this.record.note.length > 0) {
        Text(this.record.note)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })

    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: 'chart', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
      Text(this.pbHint)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)

    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: 'refresh', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      Text(this.sessionHint)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  FooterActions() {
    AppButton({
      label: this.isFavorite ? '取消收藏' : '收藏训练',
      variant: 'secondary',
      onTap: (): void => {
        void this.toggleFavorite()
      }
    })
    AppButton({
      label: '编辑复盘',
      onTap: (): void => {
        this.draft = SportRecordService.fromRecord(this.record)
        this.formError = ''
        this.showEdit = true
      }
    })
    AppButton({
      label: this.confirmDelete ? '确认删除此记录' : '删除记录',
      variant: this.confirmDelete ? 'danger' : 'secondary',
      onTap: (): void => {
        void this.handleDelete()
      }
    })
  }

  @Builder
  EditSheet() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('编辑竞技复盘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => {
            this.showEdit = false
          })
      }
      .width('100%')
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppDatePickerField({
            label: '运动日期',
            value: this.draft.recordDate,
            onChange: (v: string): void => {
              this.draft.recordDate = v
            }
          })
          this.FieldRow('时长（分钟）', this.draft.durationMin, (v: string): void => {
            this.draft.durationMin = v
          })
          this.FieldRow('距离（公里）', this.draft.distanceKm, (v: string): void => {
            this.draft.distanceKm = v
          })
          this.FieldRow('本场收获', this.draft.takeaway, (v: string): void => {
            this.draft.takeaway = v
          }, '今天做对了什么')
          this.FieldRow('下次重点', this.draft.nextFocus, (v: string): void => {
            this.draft.nextFocus = v
          }, '下次只改一件事')
          if (this.formError.length > 0) {
            Text(this.formError)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
          }
          AppButton({
            label: '保存修改',
            onTap: (): void => {
              void this.saveEdit()
            }
          })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .padding({ top: Theme.space.s6 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  FieldRow(label: string, value: string, onChange: (v: string) => void, placeholder: string = '') {
    Column({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: value, placeholder: placeholder })
        .onChange((v: string) => {
          onChange(v)
        })
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .padding(Theme.space.s3)
        .border({ width: 1, color: Theme.colors().strokeHairline })
    }
    .width('100%')
  }

  private async saveEdit(): Promise<void> {
    const res = SportRecordService.applyDraft(this.record.id, this.draft)
    if (!res.ok) {
      this.formError = res.message
      return
    }
    res.record.createdAt = this.record.createdAt
    await SportStore.save(res.record)
    this.applyRecord(SportModelClone.record(res.record))
    this.showEdit = false
    this.onChanged()
  }

  private async toggleFavorite(): Promise<void> {
    this.isFavorite = await FavoriteStore.toggleRecord(this.record.id)
    this.onChanged()
  }

  private async handleDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await FavoriteStore.removeByRecordId(this.record.id)
    await SportStore.remove(this.record.id)
    this.onChanged()
    SportDetailNav.close()
  }
}
