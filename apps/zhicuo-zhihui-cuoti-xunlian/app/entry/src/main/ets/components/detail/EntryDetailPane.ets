import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { CatalogOptions } from '../../services/AnalyzeEngine'
import { WrongMedia } from '../../services/WrongMedia'
import { WrongEntry } from '../../models/WrongModels'

@Component
export struct EntryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: WrongEntry = new WrongEntry()
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onToggle: () => void = () => {}
  onDelete: () => void = () => {}

  build() {
    DetailShell({ title: '错题详情', onClose: () => this.onClose() }) {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(WrongMedia.resource(this.entry.coverKey.length > 0 ?
            this.entry.coverKey : WrongMedia.subjectCover(this.entry.subjectCode)))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(11,31,74,0.05)', 0], ['rgba(11,31,74,0.78)', 1]]
            })
          Column({ space: 6 }) {
            Text(`${CatalogOptions.subjectLabel(this.entry.subjectCode)} · ${CatalogOptions.statusLabel(this.entry.status)}`)
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(this.entry.stem)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(3)
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
        }
        .width('100%')
        .borderRadius(Theme.radius.md)
        .clip(true)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        if (this.entry.photoUri.length > 0) {
          Image(this.entry.photoUri)
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Contain)
            .borderRadius(Theme.radius.sm)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column({ space: Theme.space.s3 }) {
          AppCard({ title: '摘要' }) {
            Text(`知识点 ${this.entry.knowledgeTag.length > 0 ? this.entry.knowledgeTag : '未填写'} · 错因 ${CatalogOptions.causeLabel(this.entry.causeCode)}`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '题目与答案' }) {
            Column({ space: Theme.space.s2 }) {
              Text(this.entry.stem)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`我的答案：${this.entry.wrongAnswer.length > 0 ? this.entry.wrongAnswer : '未填'}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandAccent)
                .width('100%')
              Text(`正确答案：${this.entry.correctAnswer.length > 0 ? this.entry.correctAnswer : '未填'}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().success)
                .width('100%')
              if (this.entry.remark.length > 0) {
                Text(`备注：${this.entry.remark}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
            }
          }
          AppButton({
            label: this.entry.status === 'mastered' ? '改回待复习' : '标记已掌握',
            onTap: () => this.onToggle()
          })
          AppButton({
            label: '编辑这道题',
            variant: 'secondary',
            onTap: () => this.onEdit()
          })
          AppButton({
            label: '删除这道题',
            variant: 'danger',
            onTap: () => this.onDelete()
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
    }
  }
}
