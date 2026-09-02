import { StartInspectForm } from './StartInspectForm'
import { ChecklistPane } from './ChecklistPane'
import { NewIssueForm } from './NewIssueForm'
import { RectifyForm } from './RectifyForm'
import { ProjectForm } from './ProjectForm'
import { FeedbackPane } from './FeedbackPane'
import { AboutPane } from './AboutPane'
import { NoticesPane } from './NoticesPane'
import { ProjectsPane } from './ProjectsPane'
import { IssueDetailPane } from '../detail/IssueDetailPane'
import { InspectDetailPane } from '../detail/InspectDetailPane'
import { ProjectDetailPane } from '../detail/ProjectDetailPane'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct QualityOverlayHost {
  @StorageLink('qualityKind') kind: string = 'none'
  @StorageLink('qualityId') entityId: string = ''
  @StorageLink('qualityExtra') extra: string = ''

  private isOpen(): boolean {
    return this.kind.length > 0 && this.kind !== 'none'
  }

  build() {
    if (!this.isOpen()) {
      Column()
        .width(0)
        .height(0)
    } else {
      Column() {
        if (this.kind === 'start') {
          StartInspectForm({
            onCancel: () => QualityNav.close(),
            onStarted: (id: string) => QualityNav.open('checklist', id)
          })
        } else if (this.kind === 'checklist') {
          ChecklistPane({
            inspectId: this.entityId,
            onBack: () => QualityNav.open('inspect', this.entityId),
            onDone: (id: string) => {
              QualityNav.toast('巡查已完成')
              QualityNav.open('inspect', id)
            },
            onCreateIssue: (inspectId: string, title: string) => QualityNav.open('newIssue', inspectId, title)
          })
        } else if (this.kind === 'newIssue') {
          NewIssueForm({
            inspectId: this.entityId,
            presetTitle: this.extra,
            issueId: '',
            onCancel: () => QualityNav.close(),
            onSaved: (id: string) => {
              QualityNav.toast('保存成功')
              QualityNav.open('issue', id)
            }
          })
        } else if (this.kind === 'editIssue') {
          NewIssueForm({
            inspectId: '',
            presetTitle: '',
            issueId: this.entityId,
            onCancel: () => QualityNav.open('issue', this.entityId),
            onSaved: (id: string) => {
              QualityNav.toast('保存成功')
              QualityNav.open('issue', id)
            }
          })
        } else if (this.kind === 'issue') {
          IssueDetailPane({
            issueId: this.entityId,
            onBack: () => QualityNav.close(),
            onRectify: (id: string) => QualityNav.open('rectify', id),
            onEdit: (id: string) => QualityNav.open('editIssue', id)
          })
        } else if (this.kind === 'inspect') {
          InspectDetailPane({
            inspectId: this.entityId,
            onBack: () => QualityNav.close(),
            onOpenIssue: (id: string) => QualityNav.open('issue', id),
            onResume: (id: string) => QualityNav.open('checklist', id)
          })
        } else if (this.kind === 'project') {
          ProjectDetailPane({
            projectId: this.entityId,
            onBack: () => QualityNav.close(),
            onOpenIssue: (id: string) => QualityNav.open('issue', id),
            onStart: () => QualityNav.open('start')
          })
        } else if (this.kind === 'rectify') {
          RectifyForm({
            issueId: this.entityId,
            onCancel: () => QualityNav.open('issue', this.entityId),
            onSubmitted: () => {
              QualityNav.toast('整改结果已提交')
              QualityNav.open('issue', this.entityId)
            }
          })
        } else if (this.kind === 'newProject') {
          ProjectForm({
            onCancel: () => QualityNav.close(),
            onSaved: (id: string) => {
              QualityNav.toast('保存成功')
              QualityNav.open('project', id)
            }
          })
        } else if (this.kind === 'messages') {
          NoticesPane({ onClose: () => QualityNav.close() })
        } else if (this.kind === 'projects') {
          ProjectsPane({ onClose: () => QualityNav.close() })
        } else if (this.kind === 'feedback') {
          FeedbackPane({ onClose: () => QualityNav.close() })
        } else if (this.kind === 'about') {
          AboutPane({ onClose: () => QualityNav.close() })
        } else {
          Column()
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
