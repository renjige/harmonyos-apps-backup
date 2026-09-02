import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppointmentItem, AppointmentTemplate } from '../../models/AppointmentModels'
import { AppointmentMedia } from '../../services/AppointmentMedia'
import { ScheduleEngine } from '../../services/ScheduleEngine'

@Component
export struct SectionTitle {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop action: string = ''
  onAction: () => void = () => {}

  build() {
    Row() {
      Text(this.title)
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Blank()
      if (this.action.length > 0) {
        Text(this.action)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onAction() })
      }
    }
    .width('100%')
  }
}

@Component
export struct AppointmentRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop meta: string = ''
  @Prop timeLabel: string = ''
  @Prop done: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Column() {
        AppIcon({
          name: this.done ? 'check' : 'message',
          iconSize: Theme.icon.md,
          color: this.done ? Theme.colors().success : Theme.colors().brandPrimary
        })
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.done ? Theme.colors().successContainer : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: this.done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.timeLabel.length > 0) {
          Text(this.timeLabel)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.meta.length > 0) {
          Text(this.meta)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 4, right: 4 })
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct AppointmentMiniCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop meta: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Column()
          .width(4)
          .height(36)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          Text(this.meta)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct TemplateMiniCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop template: AppointmentTemplate = new AppointmentTemplate()
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Image(AppointmentMedia.cover(this.template.coverKey))
        .width('100%')
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Text(this.template.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .width('100%')
      Text(this.template.summary.length > 0 ? this.template.summary : '一键创建约定')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct StatChip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop value: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .alignItems(HorizontalAlign.Center)
  }
}

export class AppointmentCardUtil {
  static rowMeta(item: AppointmentItem): string {
    let text = `${item.sceneLabel()} · ${item.remindBeforeLabel()} · ${item.repeatLabel()}`
    if (item.isImportant()) {
      text = `重要 · ${text}`
    }
    if (item.pinned) {
      text = `置顶 · ${text}`
    }
    if (item.contactName.length > 0) {
      text = `${text} · 与 ${item.contactName}`
    }
    if (item.bufferMin > 0) {
      text = `${text} · 路上 ${item.bufferMin} 分`
    }
    const prep = ScheduleEngine.prepProgress(item)
    if (prep.length > 0) {
      text = `${text} · ${prep}`
    }
    return text
  }

  static shareFallback(item: AppointmentItem): string {
    return `${item.title}\n${item.dateTimeLabel()}\n${AppointmentCardUtil.rowMeta(item)}`
  }
}
